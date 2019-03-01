// Copyright (c) 2019 K Team. All Rights Reserved.
package org.kframework.unparser;

import org.kframework.attributes.Att;
import org.kframework.definition.Definition;
import org.kframework.definition.Module;
import org.kframework.definition.ModuleComment;
import org.kframework.definition.Production;
import org.kframework.definition.Rule;
import org.kframework.definition.Sentence;
import org.kframework.definition.SyntaxPriority;
import org.kframework.definition.SyntaxSort;
import org.kframework.kore.InjectedKLabel;
import org.kframework.kore.K;
import org.kframework.kore.KApply;
import org.kframework.kore.KAs;
import org.kframework.kore.KRewrite;
import org.kframework.kore.KSequence;
import org.kframework.kore.KToken;
import org.kframework.kore.KVariable;
import org.kframework.utils.errorsystem.KEMException;
import org.kframework.utils.StringUtil;

import java.io.IOException;
import java.io.DataOutputStream;
import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;

import java.util.Arrays;
import java.util.Optional;
import java.util.regex.Pattern;

import scala.collection.JavaConverters;

/**
 * Writes a KAST term to the LaTeX format.
 */
public class ToLatex {

    public static byte[] apply(K k) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            apply(new DataOutputStream(out), k);
            return out.toByteArray();
        } catch (IOException e) {
            throw KEMException.criticalError("Could not write K term to LaTeX", e, k);
        }
    }

    private static String[] asciiReadableEncodingLatexCalc() {
        String[] latexEncoder = Arrays.copyOf(StringUtil.asciiReadableEncodingDefault, StringUtil.asciiReadableEncodingDefault.length);
        latexEncoder[0x30] = "Zero";
        latexEncoder[0x31] = "I";
        latexEncoder[0x32] = "II";
        latexEncoder[0x33] = "III";
        latexEncoder[0x34] = "IV";
        latexEncoder[0x35] = "V";
        latexEncoder[0x36] = "VI";
        latexEncoder[0x37] = "VII";
        latexEncoder[0x38] = "VIII";
        latexEncoder[0x39] = "IX";
        latexEncoder[0x7a] = "ActZ";
        return latexEncoder;
    }

    public static final Pattern identChar = Pattern.compile("[A-Za-y]");
    public static String[] asciiReadableEncodingLatex = asciiReadableEncodingLatexCalc();

    public static String latexedKLabel(String orig) {
        StringBuilder buffer = new StringBuilder();
        StringUtil.encodeStringToAlphanumeric(buffer, orig, asciiReadableEncodingLatex, identChar, "z");
        return "klabel" + buffer.toString();
    }

    private static void writeString(DataOutputStream out, String str) throws IOException {
        out.write(str.getBytes(StandardCharsets.UTF_8));
    }

    public static void apply(DataOutputStream out, Att att) throws IOException {
        writeString(out, ("\\outerAtt{" + att.toString() + "}"));
    }

    public static void apply(DataOutputStream out, Definition def) throws IOException {
        writeString(out, ("\\outerDefinition{"));
        for (Module mod: JavaConverters.seqAsJavaList(def.modules().toSeq())) {
            apply(out, mod);
        }
        writeString(out, "}{");
        apply(out, def.att());
        writeString(out, "}");
    }

    public static void apply(DataOutputStream out, Module mod) throws IOException {
        writeString(out, ("\\outerModule{" + mod.name() + "}{"));
        for (Module m: JavaConverters.seqAsJavaList(mod.imports().toSeq())) {
            writeString(out, "\\outerImport{" + m.name() + "}");
        }
        writeString(out, "}{");
        for (Sentence sent: JavaConverters.seqAsJavaList(mod.localSentences().toSeq())) {
            apply(out, sent);
        }
        writeString(out, ("}{" + mod.att() + "}"));
    }

    public static byte[] apply(Sentence sent) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            apply(new DataOutputStream(out), sent);
            return out.toByteArray();
        } catch (IOException e) {
            throw KEMException.criticalError("Could not write K term to LaTeX", e, sent);
        }
    }

    public static void apply(DataOutputStream out, Sentence sent) throws IOException {
        if (sent instanceof Rule) {
            Rule rule = (Rule) sent;
            writeString(out, "\\outerRule{");
            apply(out, rule.body());
            writeString(out, "}{");
            apply(out, rule.requires());
            writeString(out, "}{");
            apply(out, rule.ensures());
            writeString(out, "}{");
            apply(out, rule.att());
            writeString(out, "}");

        } else if (sent instanceof ModuleComment) {
            ModuleComment moduleComment = (ModuleComment) sent;
            writeString(out, "\\outerModuleComment{" + moduleComment.comment() + "}{");
            apply(out, moduleComment.att());
            writeString(out, "}");

        } else {
            KEMException.criticalError("Do not know how to serialize sentence: " + sent.toString());
        }
    }

    public static void apply(DataOutputStream out, K k) throws IOException {
        if (k instanceof KToken) {
            KToken tok = (KToken) k;

            writeString(out, ("\\texttt{ " + tok.s() + " }"));

        } else if (k instanceof KApply) {
            KApply app = (KApply) k;

            writeString(out, ("\\" + latexedKLabel(app.klabel().name())));

            for (K item : app.klist().asIterable()) {
                writeString(out, "{");
                apply(out, item);
                writeString(out, "}");
            }

        } else if (k instanceof KSequence) {
            KSequence kseq = (KSequence) k;

            writeString(out, "\\kseq{");

            for (K item : kseq.asIterable()) {
                apply(out, item);
                writeString(out, "}{\\kseq{");
            }

            writeString(out, "}{\\dotk{}}");

        } else if (k instanceof KVariable) {
            KVariable var = (KVariable) k;

            Optional<String> origName = var.att().getOptional("originalName");
            if (origName.isPresent()) {
                writeString(out, origName.get());
            } else {
                writeString(out, var.name());
            }

        } else if (k instanceof KRewrite) {
            KRewrite rew = (KRewrite) k;

            writeString(out, "\\krewrites{");
            apply(out, rew.left());
            writeString(out, "}{");
            apply(out, rew.right());
            writeString(out, "}{");
            apply(out, rew.att());
            writeString(out, "}");

        } else if (k instanceof KAs) {
            KAs alias = (KAs) k;

            writeString(out, "\\kas{");
            apply(out, alias.pattern());
            writeString(out, "}{");
            apply(out, alias.alias());
            writeString(out, "}{");
            apply(out, alias.att());
            writeString(out, "}");

        } else if (k instanceof InjectedKLabel) {
            InjectedKLabel inj = (InjectedKLabel) k;

            writeString(out, "\\injectedklabel{");
            writeString(out, inj.klabel().name());
            writeString(out, "}");

        } else {
            throw KEMException.criticalError("Unimplemented for LaTeX serialization: ", k);
        }
    }
}
