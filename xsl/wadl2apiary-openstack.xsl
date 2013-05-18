<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:db="http://docbook.org/ns/docbook"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text"/>
    
 
    
    
    

    
    <xsl:template match="db:book">HOST: http://localhost:5000<!--<xsl:value-of select="//wadl:resources/@base"/>-->        
--- <xsl:value-of select="(//db:title)[1]"/> ---
<xsl:apply-templates/>        
    </xsl:template>
    
   <xsl:template match="db:preface">
---       
<xsl:apply-templates/>
---       
   </xsl:template> 
    
   <xsl:template match="db:title[parent::db:preface]"/>
   <xsl:template match="db:link">[<xsl:apply-templates/>](<xsl:value-of select="@xlink:href"/>)</xsl:template>
   <xsl:template match="db:citetitle">*<xsl:apply-templates/>*</xsl:template>

<xsl:template match="db:chapter|db:section"><xsl:text>
    
</xsl:text>
--
<xsl:value-of select="db:title"/><xsl:text>
    
</xsl:text><xsl:apply-templates select="db:para"/>--
<xsl:apply-templates select="wadl:resource"/>
<xsl:apply-templates select="db:section"/>    
</xsl:template>

<xsl:template match="wadl:method[parent::wadl:resource]">
        
<xsl:if test="wadl:doc/@title">
    
### <xsl:value-of select="wadl:doc/@title"/>

</xsl:if>        
<xsl:for-each select="wadl:doc">
<xsl:apply-templates select="db:para|html:p"/>
</xsl:for-each><xsl:text>
           
</xsl:text>
<xsl:text>
    
</xsl:text>        
    <xsl:value-of select="@name"/><xsl:text> </xsl:text><xsl:value-of select="if (starts-with(parent::wadl:resource/@path, '/')) then parent::wadl:resource/@path else concat('/', parent::wadl:resource/@path)"/>
<xsl:apply-templates select="wadl:request"/><xsl:apply-templates select="wadl:response"/>
    </xsl:template>
    
    <xsl:template match="wadl:request">
> Content-Type: application/json
> Accept: application/json<xsl:choose>
<xsl:when test="wadl:representation[@mediaType = 'application/json']/wadl:doc/db:example/db:programlisting">
<xsl:value-of select="normalize-space((wadl:representation[@mediaType = 'application/json']/wadl:doc/db:example/db:programlisting)[1])"/></xsl:when><xsl:otherwise/></xsl:choose>    
</xsl:template>   


    <xsl:template match="wadl:response[not(starts-with(@status,'2'))]"/>
        
    <xsl:template match="wadl:response[starts-with(@status,'2')]">
&lt; <xsl:value-of select="tokenize(@status,' ')[1]"/> 
<xsl:choose><xsl:when test="not(ancestor::wadl:method/@name = 'HEAD') and 
    not(./wadl:representation[@mediaType = 'application/json'])">
&lt; Content-Type: application/json
&lt;&lt;&lt;EOT
{}
EOT
</xsl:when><xsl:when test="ancestor::wadl:method/@name = 'HEAD'"><xsl:text>
    
    
    
    
</xsl:text></xsl:when></xsl:choose>
 <xsl:apply-templates select="wadl:representation"/>    
    </xsl:template>
    
    <xsl:template match="wadl:representation">
&lt; Content-Type: <xsl:value-of select="@mediaType"/><xsl:text>
</xsl:text><xsl:choose><xsl:when test="not(.//db:example/db:programlisting)">&lt;&lt;&lt;EOT
{}
EOT
</xsl:when><xsl:otherwise>&lt;&lt;&lt;EOT
<xsl:value-of select=".//db:example/db:programlisting"/>
EOT</xsl:otherwise></xsl:choose>       
    </xsl:template>
    <xsl:template match="text()"/>
    <xsl:template match="wadl:grammars"/>

<xsl:template match="db:para|html:p"><xsl:text>
    
</xsl:text>
<xsl:value-of select="normalize-space(.)"/><xsl:text>
    
</xsl:text>
</xsl:template>
    
    <xsl:template match="wadl:method[parent::wadl:application]|wadl:resource_type|wadl:param|db:para[@role='shortdesc' or parent::wadl:doc[parent::wadl:resource]]|html:p[@class='shortdesc' or parent::wadl:doc[parent::wadl:resource]]"/>
    <xsl:template match="wadl:method/text()|wadl:resources/text()|db:book/db:title"/>
    <xsl:template match="wadl:representation[not(@mediaType = 'application/json')]"/>
</xsl:stylesheet>