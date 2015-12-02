<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="actors">
        <xsl:for-each select="//tei:castItem/tei:actor/@xml:id">
            <actor><xsl:value-of select="substring-after(.,'sp.')"/></actor>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:template match="@* | node()" mode="pass1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass1"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:sp" mode="pass1">
        <sp>
            <xsl:variable name="govornikovo-ime">
                <xsl:choose>
                    <xsl:when test="starts-with(tei:speaker,'PREDSEDNIK')">
                        <xsl:value-of select="translate(substring-after(tei:speaker,'PREDSEDNIK '),':','')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(tei:speaker,'PODPREDSEDNIK')">
                        <xsl:value-of select="translate(substring-after(tei:speaker,'PODPREDSEDNIK '),':','')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(tei:speaker,'DR. ')">
                        <xsl:value-of select="translate(substring-after(tei:speaker,'DR. '),':','')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(tei:speaker,'MAG. ')">
                        <xsl:value-of select="translate(substring-after(tei:speaker,'MAG. '),':','')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="translate(tei:speaker,':','')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="govornik-imeID">
                <xsl:for-each select="tokenize($govornikovo-ime,' ')[position() eq last()]">
                    <xsl:value-of select="concat(substring(.,1,1),lower-case(substring(.,2)))"/>
                </xsl:for-each>
                <xsl:for-each select="tokenize($govornikovo-ime,' ')[position() ne last()]">
                    <xsl:value-of select="translate(concat(substring(.,1,1),lower-case(substring(.,2))),'\s\.','')"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="govornik-imeID-preverjen">
                <xsl:value-of select="$actors/tei:actor[. = $govornik-imeID]"/>
            </xsl:variable>
            <xsl:if test="tei:speaker">
                <xsl:if test="string-length($govornik-imeID-preverjen) gt 0">
                    <xsl:attribute name="who">
                        <xsl:value-of select="concat('#sp.',$govornik-imeID-preverjen)"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates mode="pass1"/>
        </sp>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass2"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:sp[not(tei:speaker)]" mode="pass2">
        <sp>
           <xsl:choose>
               <xsl:when test="preceding-sibling::tei:sp[1]/@who">
                   <xsl:attribute name="who">
                       <xsl:value-of select="preceding-sibling::tei:sp[1]/@who"/>
                   </xsl:attribute>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:choose>
                       <xsl:when test="preceding-sibling::tei:sp[2]/@who">
                           <xsl:attribute name="who">
                               <xsl:value-of select="preceding-sibling::tei:sp[2]/@who"/>
                           </xsl:attribute>
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:choose>
                               <xsl:when test="preceding-sibling::tei:sp[3]/@who">
                                   <xsl:attribute name="who">
                                       <xsl:value-of select="preceding-sibling::tei:sp[3]/@who"/>
                                   </xsl:attribute>
                               </xsl:when>
                               <xsl:otherwise>
                                   <xsl:choose>
                                       <xsl:when test="preceding-sibling::tei:sp[4]/@who">
                                           <xsl:attribute name="who">
                                               <xsl:value-of select="preceding-sibling::tei:sp[4]/@who"/>
                                           </xsl:attribute>
                                       </xsl:when>
                                       <xsl:otherwise>
                                           <xsl:choose>
                                               <xsl:when test="preceding-sibling::tei:sp[5]/@who">
                                                   <xsl:attribute name="who">
                                                       <xsl:value-of select="preceding-sibling::tei:sp[5]/@who"/>
                                                   </xsl:attribute>
                                               </xsl:when>
                                               <xsl:otherwise>
                                                   <xsl:choose>
                                                       <xsl:when test="preceding-sibling::tei:sp[6]/@who">
                                                           <xsl:attribute name="who">
                                                               <xsl:value-of select="preceding-sibling::tei:sp[6]/@who"/>
                                                           </xsl:attribute>
                                                       </xsl:when>
                                                       <xsl:otherwise>
                                                           <xsl:choose>
                                                               <xsl:when test="preceding-sibling::tei:sp[7]/@who">
                                                                   <xsl:attribute name="who">
                                                                       <xsl:value-of select="preceding-sibling::tei:sp[7]/@who"/>
                                                                   </xsl:attribute>
                                                               </xsl:when>
                                                               <xsl:otherwise>
                                                                   <xsl:choose>
                                                                       <xsl:when test="preceding-sibling::tei:sp[8]/@who">
                                                                           <xsl:attribute name="who">
                                                                               <xsl:value-of select="preceding-sibling::tei:sp[8]/@who"/>
                                                                           </xsl:attribute>
                                                                       </xsl:when>
                                                                   </xsl:choose>
                                                               </xsl:otherwise>
                                                           </xsl:choose>
                                                       </xsl:otherwise>
                                                   </xsl:choose>
                                               </xsl:otherwise>
                                           </xsl:choose>
                                       </xsl:otherwise>
                                   </xsl:choose>
                               </xsl:otherwise>
                           </xsl:choose>
                       </xsl:otherwise>
                   </xsl:choose>
               </xsl:otherwise>
           </xsl:choose> 
            <xsl:apply-templates mode="pass2"/>
        </sp>
    </xsl:template>
    
    <!-- Vključena classDecl/taxonomy -->
    <xsl:template match="tei:classDecl" mode="pass2">
        <xsl:text disable-output-escaping="yes"><![CDATA[<xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="taxonomy.xml"/>]]></xsl:text>
    </xsl:template>
    
    
    <xsl:variable name="v-pass1">
        <xsl:apply-templates mode="pass1" select="/"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:apply-templates mode="pass2" select="$v-pass1"/>
    </xsl:template>
    
    
</xsl:stylesheet>