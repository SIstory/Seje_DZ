<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- NAVODILA PRED PRETVORBO:
         - Iz shranjene HTMl strani glede na pot do elementa fieldset (lahko ga tudi najdeš, saj je edini) 
           /html/body[1]/div[1]/table[1]/tbody[1]/tr[1]/td[1]/div[4]/table[1]/tbody[1]/tr[1]/td[1]/div[2]/table[1]/tbody[1]/tr[1]/td[1]/table[1]/tbody[1]/tr[1]/td[1]/div[1]/link[1]/form[1]/input[1]/table[1]/tbody[1]/tr[4]/td[1]/fieldset[1]
           kopiraj element fieldset in ga prilepi v istoimenski XML dokument.
         - V XML dokumentu
              - popravi <br> zapis v <br/>,
              - zamenjal &nbsp; z &#xA0;
              - če je fieldset element označen kot atribut div elementa, ta div spremeni v fieldset!!
              - indent;
              - v elementu fieldset ustvari atribute (s vsebino):
                   - url
                   - urlWhen
                   - who (Skupščina Republike Slovenije ali Državni zbor Republike Slovenije)
                   - mandat
                   
         NAVODILA PO PRETVORBI s tem XSL stilom:
         - uredi do konca list s kazalom vsebine:
              - združi razpršeni zapis točk kazala po različnih item;
              - seznam govornikov premakni v na novo narejeni list[@rend = 'simple'] zgornje točke;
         - popravi napačne actor/xml:id v seznamu govornikov;
         - označi predsednika kot govornika (/TEI/text/body/div[1]/div[1]/castList);
         - odstrani prazne prostore na začetku besedila v <p>;
         - v //sp popravi napačne pretvorbe:
             - v glavnem napačno označeni speaker
             - označi naslove zapisane z velikimi črkami z title
             
         PRETVORBA z DZ-addWho.xsl. Po pretvorbi ročno uredi še:
         - dodaj neoznačene sp/@who;
         - dodaj div/@ana strukturo besedila
         - indent
         
         Ko pretvoriš stari XML dokument v novega in ga do konca urediš po zgornjih navodilih, 
         - originalni HTML premakni v podmapo sources;
         - stari XML premakni v podmapo sources;
         - namesto starega XML na njegovem mestu shrani pretvorjen XML z istim imenom.
    -->
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="fieldset" mode="pass1">
        <root>
            <id><xsl:value-of select="@id"/></id>
            <url><xsl:value-of select="@url"/></url>
            <urlWhen><xsl:value-of select="@urlWhen"/></urlWhen>
            <who><xsl:value-of select="@who"/></who>
            <mandat><xsl:value-of select="@mandat"/></mandat>
            <xsl:for-each select="span[@class='outputText']">
                <!-- razdeli na  tri sklope: govori, vsebina (kazalo) in seznam govornikov -->
                <xsl:for-each-group select="*" group-starting-with="div[@align='center'][name(preceding-sibling::*[1]) = 'font' or name(preceding-sibling::*[1]) = 'tt']">
                    <skupina>
                        <xsl:for-each select="current-group()">
                            <xsl:copy>
                                <xsl:apply-templates/>
                            </xsl:copy>
                        </xsl:for-each>
                    </skupina>
                </xsl:for-each-group>
            </xsl:for-each>
        </root>
    </xsl:template>
    
    <xsl:template match="root" mode="pass2">
        <root>
            <xsl:copy-of select="id"/>
            <xsl:copy-of select="url"/>
            <xsl:copy-of select="urlWhen"/>
            <xsl:copy-of select="who"/>
            <xsl:copy-of select="mandat"/>
            <govori>
                <xsl:for-each select="skupina[2]">
                    <!-- skupina tam, kjer so prej trije br drug za drugim -->
                    <xsl:for-each-group select="*" group-starting-with="br[name(preceding-sibling::*[1]) = 'br' and name(preceding-sibling::*[2]) = 'br']">
                        <govori-skupina>
                            <xsl:for-each select="current-group()">
                                <xsl:copy>
                                    <xsl:apply-templates/>
                                </xsl:copy>
                            </xsl:for-each>
                        </govori-skupina>
                    </xsl:for-each-group>
                </xsl:for-each>
            </govori>
            <div type="contents">
                <xsl:for-each select="skupina[3]">
                    <head><xsl:value-of select="div[1]"/></head>
                    <list rend="simple">
                        <head><xsl:value-of select="div[2]"/></head>
                        <head><xsl:value-of select="div[3]"/></head>
                        <xsl:for-each select="tt">
                            <xsl:choose>
                                <xsl:when test="matches(.,'^(\d+)(\.\s)(.*?)$','ms')">
                                    <xsl:analyze-string select="." regex="^(\d+)(\.\s)(.*?)$" flags="ms">
                                        <xsl:matching-substring>
                                            <item n="{regex-group(1)}"><xsl:value-of select="normalize-space(regex-group(3))"/></item>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:value-of select="."/>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:when>
                                <xsl:when test="matches(.,'[A-ZČŠŽ]+') and not(matches(.,'[a-zčšž]'))">
                                    <head><xsl:value-of select="normalize-space(.)"/></head>
                                </xsl:when>
                                <xsl:otherwise>
                                    <item><xsl:value-of select="."/></item>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </list>
                </xsl:for-each>
            </div>
            <div type="govorniki">
                <xsl:for-each select="skupina[4]">
                    <head><xsl:value-of select="div[1]"/></head>
                    <head><xsl:value-of select="concat(div[2],' ',div[3])"/></head>
                    <castList>
                        <head><xsl:value-of select="tt[1]"/></head>
                        <xsl:for-each select="tt[position() gt 1]">
                            <castItem><xsl:value-of select="normalize-space(.)"/></castItem>
                        </xsl:for-each>
                    </castList>
                </xsl:for-each>
            </div>
        </root>
    </xsl:template>
    
    <xsl:template match="root" mode="pass3">
        <root>
            <xsl:copy-of select="id"/>
            <xsl:copy-of select="url"/>
            <xsl:copy-of select="urlWhen"/>
            <xsl:copy-of select="who"/>
            <xsl:copy-of select="mandat"/>
            <xsl:copy-of select="div[@type='contents']"/>
            <!-- seznam govornikov -->
            <xsl:for-each select="div[@type='govorniki']">
                <div>
                    <xsl:for-each select="head">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                    <xsl:for-each select="castList">
                        <castList>
                            <xsl:copy-of select="head"/>
                            <xsl:for-each select="castItem">
                                <castItem>
                                    <xsl:analyze-string select="." regex="^(.*?)(\s)(.*?)(\s\.\.)(.*)$" flags="m">
                                        <xsl:matching-substring>
                                            <actor xml:id="sp.{regex-group(1)}{regex-group(3)}">
                                                <xsl:value-of select="normalize-space(concat(regex-group(1),regex-group(2),regex-group(3)))"/>
                                            </actor>
                                            <xsl:value-of select="concat(regex-group(4),regex-group(5))"/>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:value-of select="."/>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </castItem>
                            </xsl:for-each>
                        </castList>
                    </xsl:for-each>
                </div>
            </xsl:for-each>
            <!-- govori -->
            <div>
                <xsl:for-each select="govori/govori-skupina[1]">
                    <head><xsl:value-of select="div[1]"/></head>
                    <div>
                        <head><xsl:value-of select="div[2]"/></head>
                        <docDate><xsl:value-of select="div[3]"/></docDate>
                        <castList>
                            <castItem><xsl:value-of select="tt[1]"/></castItem>
                        </castList>
                        <stage><xsl:value-of select="tt[2]"/></stage>
                        <xsl:for-each select="../govori-skupina[2]">
                            <xsl:for-each-group select="*" group-ending-with="br[name(preceding-sibling::*[1]) = 'br']">
                                <sp>
                                    <xsl:for-each select="current-group()">
                                        <xsl:copy>
                                            <xsl:apply-templates/>
                                        </xsl:copy>
                                    </xsl:for-each>
                                </sp>
                            </xsl:for-each-group>
                        </xsl:for-each>
                    </div>
                </xsl:for-each>
            </div>
        </root>
    </xsl:template>
    
    <xsl:template match="root" mode="pass4">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Evidenca zapisa seje</title>
                        <title><xsl:value-of select="who"/></title>
                        <title><xsl:value-of select="concat('Mandat: ',mandat)"/></title>
                        <title><xsl:value-of select="div[3]/head"/></title>
                        <title><xsl:value-of select="concat(div[3]/div/head,' ',div[3]/div/docDate)"/></title>
                        <title>Elektronska izdaja</title>
                        <editor>Državni zbor Republike Slovenije</editor>
                        <respStmt>
                            <persName>Andrej Pančur</persName>
                            <resp>Kodiranje TEI in računalniški zapis</resp>
                        </respStmt>
                        <respStmt>
                            <persName>Andrej Pančur</persName>
                            <resp>Pretvorba iz HTML v TEI</resp>
                        </respStmt>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>Inštitut za novejšo zgodovino, Zgodovina Slovenije - SIstory</publisher>
                        <distributor>DARIAH-SI</distributor>
                        <idno type="URN">http://www.sistory.si/SISTORY:ID:</idno>
                        <pubPlace>http://www.sistory.si/SISTORY:ID:</pubPlace>
                        <pubPlace>https://github.com/SIstory/Seje_DZ/tree/master/</pubPlace>
                        <availability status="free">
                            <licence>http://creativecommons.org/licenses/by/4.0/</licence>
                            <p>To delo je ponujeno pod <ref target="http://creativecommons.org/licenses/by/4.0/"
                                >Creative Commons Priznanje avtorstva 4.0 International licenco</ref></p>
                        </availability>
                        <date when="{current-date()}"/>
                    </publicationStmt>
                    <sourceDesc>
                        <biblStruct>
                            <analytic>
                                <idno><xsl:value-of select="id"/></idno>
                                <title><xsl:value-of select="div[3]/head"/></title>
                                <title><xsl:value-of select="div[3]/div/head"/></title>
                            </analytic>
                            <monogr>
                                <title>Evidenca zapisa seje</title>
                                <title><xsl:value-of select="who"/></title>
                                <title><xsl:value-of select="concat('Mandat: ',mandat)"/></title>
                                <imprint>
                                    <publisher>Državni zbor Republike Slovenije</publisher>
                                    <date><xsl:value-of select="div[3]/div/docDate"/></date>
                                </imprint>
                            </monogr>
                            <ref target="{url}">(<date><xsl:value-of select="urlWhen"/></date>)</ref>
                        </biblStruct>
                        <biblFull>
                            <titleStmt>
                                <title>Evidenca zapisa seje</title>
                                <title><xsl:value-of select="who"/></title>
                                <title><xsl:value-of select="concat('Mandat: ',mandat)"/></title>
                            </titleStmt>
                            <publicationStmt>
                                <publisher>Državni zbor Republike Slovenije</publisher>
                                <availability status="free">
                                    <licence target="http://creativecommons.org/publicdomain/mark/1.0/"
                                        xml:lang="slv">Avtorske pravice so potekle, delo je v javni
                                        domeni.</licence>
                                    <licence target="http://creativecommons.org/publicdomain/mark/1.0/"
                                        xml:lang="eng">Public Domain Mark 1.0</licence>
                                </availability>
                            </publicationStmt>
                        </biblFull>
                    </sourceDesc>
                </fileDesc>
                <encodingDesc>
                    <projectDesc>
                        <p>XML na portalu Zgodovina Slovenije - SIstory narejen v okviru izvajanja
                            infrastrukturnega programa Inštituta za novejšo zgodovino</p>
                    </projectDesc>
                    <!-- Vključena classDecl/taxonomy -->
                    <xsl:text disable-output-escaping="yes"><![CDATA[<xi:include xmlns:xi="http://www.w3.org/2001/XInclude" href="taxonomy.xml"/>]]></xsl:text>
                </encodingDesc>
                <profileDesc>
                    <langUsage>
                        <language ident="slv" xml:lang="slv">slovenski</language>
                        <language ident="slv" xml:lang="eng">Slovenian</language>
                        <language ident="en" xml:lang="sl">angleški</language>
                        <language ident="en" xml:lang="en">English</language>
                    </langUsage>
                </profileDesc>
                <revisionDesc>
                    <change when="{current-date()}">
                        <name>Andrej Pančur</name>: preveril, dopolnil in dokončal kodiranje<list>
                            <item>//front//*</item>
                            <item>//div/@ana</item>
                            <item>//stage</item>
                            <item>//head</item>
                            <item>//castList</item>
                            <item>//docDate</item>
                        </list>
                    </change>
                    <change when="{current-date()}">
                        <name>Andrej Pančur</name>: konverzija docx2tei </change>
                </revisionDesc>
            </teiHeader>
            <text>
                <front>
                    <xsl:choose>
                        <xsl:when test="div[@type='contents']/list/head[starts-with(.,'PRED DNEVNIM REDOM')]">
                            <xsl:for-each select="div[@type='contents']">
                                <div type="contents">
                                    <xsl:copy-of select="head"/>
                                    <xsl:for-each select="list">
                                        <list rend="simple">
                                            <xsl:copy-of select="head[1]"/>
                                            <xsl:copy-of select="head[2]"/>
                                            <xsl:for-each-group select="*[position() gt 2]" group-starting-with="head[starts-with(.,'PRED DNEVNIM REDOM')] | head[starts-with(.,'DNEVNI RED')]">
                                                <item>
                                                    <list rend="ordered">
                                                        <xsl:for-each select="current-group()">
                                                            <xsl:copy-of select="."/>
                                                        </xsl:for-each>
                                                    </list>
                                                </item>
                                            </xsl:for-each-group>
                                        </list>
                                    </xsl:for-each>
                                </div>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="div[@type='contents']"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <!-- govorniki -->
                    <xsl:copy-of select="div[2]"/>
                </front>
                <body>
                    <!-- govori -->
                    <xsl:for-each select="div[3]">
                        <div>
                            <xsl:copy-of select="head"/>
                            <xsl:for-each select="div">
                                <div>
                                    <xsl:copy-of select="head"/>
                                    <xsl:copy-of select="docDate"/>
                                    <xsl:copy-of select="castList"/>
                                    <xsl:copy-of select="stage"/>
                                    <xsl:for-each select="sp">
                                        <xsl:choose>
                                            <xsl:when test="not(tt[2]) and (starts-with(.,'(') or starts-with(.,'/'))">
                                                <stage><xsl:value-of select="normalize-space(tt)"/></stage>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <sp>
                                                    <speaker><xsl:value-of select="normalize-space(tt[1])"/></speaker>
                                                    <xsl:for-each select="tt[position() gt 1]">
                                                        <p><xsl:value-of select="normalize-space(.)"/></p>
                                                    </xsl:for-each>
                                                </sp>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </div>
                            </xsl:for-each>
                        </div>
                    </xsl:for-each>
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:variable name="v-pass1">
        <xsl:apply-templates mode="pass1" select="fieldset"/>
    </xsl:variable>
    <xsl:variable name="v-pass2">
        <xsl:apply-templates mode="pass2" select="$v-pass1"/>
    </xsl:variable>
    <xsl:variable name="v-pass3">
        <xsl:apply-templates mode="pass3" select="$v-pass2"/>
    </xsl:variable>
    
    <xsl:template match="fieldset">
        <xsl:apply-templates mode="pass4" select="$v-pass3"/>
    </xsl:template>
    
    
</xsl:stylesheet>