<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="@* | node()" mode="pass1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass1"/>
        </xsl:copy>
    </xsl:template>
    
   <xsl:template match="tei:speaker" mode="pass1">
       <xsl:choose>
           <xsl:when test="not(contains(.,':')) and starts-with(following-sibling::tei:p[1],':')">
               <speaker>
                   <xsl:value-of select="concat(.,':')"/>
               </speaker>
           </xsl:when>
           <xsl:otherwise>
               <xsl:copy-of select="."/>
           </xsl:otherwise>
       </xsl:choose>
   </xsl:template>
    
    <xsl:template match="tei:p" mode="pass1">
        <xsl:choose>
            <xsl:when test="starts-with(.,':') and not(contains(preceding-sibling::tei:speaker,':'))">
                <p>
                    <xsl:analyze-string select="." regex="^:\s">
                        <xsl:non-matching-substring>
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:speaker" mode="pass2">
        <xsl:choose>
            <xsl:when test="not(matches(.,'\w+')) and matches(following-sibling::tei:p[1],'^[A-ZČŠŽ\s\.]+:$')">
                <speaker>
                    <xsl:value-of select="following-sibling::tei:p[1]"/>
                </speaker>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:p" mode="pass2">
        <xsl:choose>
            <xsl:when test="preceding-sibling::*[1][self::tei:speaker] and not(matches(preceding-sibling::tei:speaker[1],'\w+')) and matches(.,'^[A-ZČŠŽ\s\.]+:$')">
                <!-- izbrišem -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass3">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass3"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:p" mode="pass3">
        <xsl:choose>
            <xsl:when test="not(matches(.,'\w+')) and matches(following-sibling::tei:p[1],'^[A-ZČŠŽ\s\.]+:$')">
                <xsl:text disable-output-escaping="yes"><![CDATA[</sp><sp>]]></xsl:text>
            </xsl:when>
            <xsl:when test="matches(.,'^[A-ZČŠŽ\s\.]+:$')">
                <speaker>
                    <xsl:value-of select="."/>
                </speaker>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
     
    <!-- Vključena classDecl/taxonomy -->
    <xsl:template match="tei:classDecl" mode="pass3">
        <xsl:text disable-output-escaping="yes"><![CDATA[<xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="taxonomy.xml"/>]]></xsl:text>
    </xsl:template>
    
    
    <xsl:variable name="v-pass1">
        <xsl:apply-templates mode="pass1" select="/"/>
    </xsl:variable>
    <xsl:variable name="v-pass2">
        <xsl:apply-templates mode="pass2" select="$v-pass1"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:apply-templates mode="pass3" select="$v-pass2"/>
    </xsl:template>
    
</xsl:stylesheet>