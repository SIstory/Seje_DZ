<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="xs tei xi" version="2.0">
    
    <!-- izhodiščni dokument teiCorpus.xml -->
    <!-- vstavi ga v isti direktorij kot teiCorpus -->
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:result-document href="actors.xml">
            <root>
                <xsl:for-each-group select="//tei:actor[@xml:id]" group-by=".">
                    <xsl:sort select="."/>
                    <actor>
                        <name>
                            <xsl:value-of select="current-grouping-key()"/>
                        </name>
                        <xsl:for-each select="current-group()">
                            <id>
                                <xsl:value-of select="concat(./@xml:id,' ',ancestor::tei:TEI/@xml:id)"/>
                            </id>
                        </xsl:for-each>
                    </actor>
                </xsl:for-each-group>
            </root>
        </xsl:result-document>
        
    </xsl:template>
    
</xsl:stylesheet>
