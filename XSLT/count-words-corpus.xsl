<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- izhodiščna datoteka je docList.xml -->
    
    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:template match="documentsList">
        <!-- naredim v direktoriju rezultat txt datoteke z golim besedilom v eni vrstici -->
        <xsl:for-each select="ref">
            <xsl:variable name="document" select="concat('rezultat/',substring-before(tokenize(.,'/')[last()],'.xml'),'.txt')"/>
            <xsl:result-document href="{$document}">
                <xsl:apply-templates select="document(.)"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <!-- Štetje besed -->
        <xsl:variable name="counting">
            <xsl:for-each select="ref">
                <string>
                    <xsl:apply-templates select="document(.)"/>
                </string>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="compoundString" select="normalize-space(string-join($counting/string,' '))"/>
        <xsl:result-document href="word_frequency-corpus.csv">
            <xsl:text>"beseda", "frekvenca"&#xa;</xsl:text>
            <xsl:for-each-group group-by="." select="for $word in tokenize($compoundString,'\W+')[. != ''] return lower-case($word)">
                <xsl:sort select="count(current-group())" order="descending"/>
                <xsl:value-of select="concat('&quot;',current-grouping-key(),'&quot;')"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="concat('&quot;',count(current-group()),'&quot;')"/>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each-group>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template match="fieldset">
        <xsl:apply-templates select="span[@class = 'outputText']"/>
    </xsl:template>
    
    <xsl:template match="span[@class = 'outputText']">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
</xsl:stylesheet>