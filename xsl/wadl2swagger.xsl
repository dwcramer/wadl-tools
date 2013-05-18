<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wadl="http://wadl.dev.java.net/2009/02"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        {
        "apiVersion": "1.0",
        "swaggerVersion": "1.1",
        "basePath": "http://localhost:5000/api",
        "apis": [
            <xsl:apply-templates/>
          ]
        }        
    </xsl:template>
        
    <xsl:template match="wadl:resource">
        {
        "path": "<xsl:value-of select="if(not(starts-with(@path,'/'))) then concat('/',@path) else @path"/>",
        "description": "<xsl:value-of select="normalize-space(wadl:doc[1])"/>",
        <xsl:if test="wadl:method">"operations": [
        <xsl:apply-templates select="wadl:method"/>
        </xsl:if>
           ]
        }<xsl:if test="following::wadl:resource">,</xsl:if>
    </xsl:template>
    
    <xsl:template match="wadl:method[parent::wadl:resource]">
        {
        "httpMethod": "<xsl:value-of select="@name"/>",
        "summary": "<xsl:value-of select="normalize-space(wadl:doc[1])"/>",
        "responseClass": "void", 
        "nickname": "<xsl:value-of select="@id"/>"
        }<xsl:if test="following-sibling::wadl:method">,</xsl:if>
    </xsl:template>
    
    <xsl:template match="text()"/>
    
</xsl:stylesheet>