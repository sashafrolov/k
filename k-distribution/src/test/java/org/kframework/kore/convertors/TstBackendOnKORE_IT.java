// Copyright (c) 2014-2015 K Team. All Rights Reserved.

package org.kframework.kore.convertors;

import org.junit.Test;
import org.junit.rules.TestName;
import org.kframework.attributes.Source;
import org.kframework.definition.Module;
import org.kframework.kore.K;
import org.kframework.parser.ProductionReference;
import org.kframework.unparser.AddBrackets;
import org.kframework.unparser.KOREToTreeNodes;
import org.kframework.utils.KoreUtils;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.Optional;

public class TstBackendOnKORE_IT {

    @org.junit.Rule
    public TestName name = new TestName();

    protected File testResource(String baseName) throws URISyntaxException {
        return new File(TstTinyOnKORE_IT.class.getResource(baseName).toURI());
    }

    @Test
    public void kore_imp() throws IOException, URISyntaxException {
        String filename = "/convertor-tests/" + name.getMethodName() + ".k";
        KoreUtils utils = new KoreUtils(filename);

        String program = "int s, n; n = 10; while(0<=n) { s = s + n; n = n + -1; }";
        K kResult = utils.stepRewrite(utils.getParsed(p), Optional.<Integer>empty());

        Module unparsingModule = utils.getUnparsingModule();
        System.err.println(KOREToTreeNodes.toString(new AddBrackets(unparsingModule).addBrackets((ProductionReference) KOREToTreeNodes.apply(KOREToTreeNodes.up(kResult), unparsingModule))));
    }

}