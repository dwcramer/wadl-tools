<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    xmlns:db="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text"/>
    

    <xsl:template match="wadl:application">HOST: <xsl:value-of select="//wadl:resources/@base"/>
        
--- <xsl:value-of select="(//wadl:doc)[1]/@title"/> ---

<xsl:apply-templates/>        
    </xsl:template>

    <xsl:template match="wadl:method[parent::wadl:resource]">
-- <xsl:value-of select="wadl:doc/@title"/> --
        
<xsl:for-each select="wadl:doc">
<xsl:apply-templates select="db:para"/>
</xsl:for-each><xsl:text>
           
</xsl:text>
<xsl:text>
    
</xsl:text>        
<xsl:value-of select="@name"/><xsl:text> </xsl:text><xsl:value-of select="parent::wadl:resource/@path"/>
<xsl:apply-templates select="wadl:request"/><xsl:apply-templates select="wadl:response"/>
    </xsl:template>
    
    <xsl:template match="wadl:request">
> Content-Type: application/json
> Accept: application/json<xsl:choose>
<xsl:when test="wadl:representation[@mediaType = 'application/json']/wadl:doc/db:example/db:programlisting">
<xsl:value-of select="normalize-space(wadl:representation[@mediaType = 'application/json']/wadl:doc/db:example/db:programlisting)"/></xsl:when><xsl:otherwise/></xsl:choose>    
</xsl:template>   
    
    <xsl:template match="wadl:response">
&lt; <xsl:value-of select="@status"/> 
<xsl:if test="not(./wadl:representation)">
&lt; Content-Type: application/json
</xsl:if>
 <xsl:apply-templates select="wadl:representation"/>    
    </xsl:template>
    
    <xsl:template match="wadl:representation">
&lt; Content-Type: <xsl:value-of select="@mediaType"/><xsl:text>
</xsl:text><xsl:copy-of select=".//db:example/db:programlisting"/>       
    </xsl:template>
    
    <xsl:template match="wadl:grammars"/>

    <xsl:template match="db:para">
<xsl:value-of select="normalize-space(.)"/>        
    </xsl:template>
    
    <xsl:template match="wadl:method[parent::wadl:application]|wadl:resource_type|wadl:param|db:para[@role='shortdesc']"/>
    <xsl:template match="wadl:method/text()|wadl:resources/text()"/>
    <xsl:template match="wadl:representation[not(@mediaType = 'application/json')]"/>
</xsl:stylesheet>