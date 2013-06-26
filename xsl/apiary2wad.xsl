<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://wadl.dev.java.net/2009/02"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0"
    xmlns:fn="http://docs.rackspace.com/xslt"
    exclude-result-prefixes="xs fn xsdxt xhtml"
    version="2.0">
    
    
    <!-- 
        TODO: Generate blob of DocBook to go with this.        
    -->
    <xsl:output indent="yes"/>
    
    <xsl:param name="wadlname" select="concat(replace(base-uri(),'.*/(.*).html','$1' ),'.wadl')"/>
    
    <xsl:template match="/">
        
        <xsl:result-document href="{$wadlname}">
        <application xmlns="http://wadl.dev.java.net/2009/02"
            xmlns:wadl="http://wadl.dev.java.net/2009/02"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0"
            xmlns:raxapi="http://docs.rackspace.com/volume/api/v1">
            
            <resources base="{/xhtml:html/xhtml:body[1]/xhtml:div[1]/xhtml:div[1]/xhtml:div[1]/xhtml:div[1]/xhtml:div[1]/xhtml:input[1]/@value}">               
                <xsl:apply-templates select="//xhtml:section[tokenize(@class, ' ') = 'resource']"/>
            </resources>
            
        </application>
        </xsl:result-document>
        
        <xsl:result-document href="apiref.xml">
            <chapter xml:id="apiref" role="api-reference" xmlns="http://docbook.org/ns/docbook">
                <title>API Reference</title>
                <xsl:apply-templates select="//xhtml:div[@class ='chapterWrapper']" mode="apiref"/>
            </chapter>
        </xsl:result-document>
        
    </xsl:template>


    <xsl:template match="xhtml:div[@class ='chapterWrapper']" mode="apiref">
        <xsl:variable name="title" select="normalize-space(xhtml:hgroup/xhtml:h1)"/>
        <xsl:variable name="badchars"> !@#$%^&amp;*()[]{}|\</xsl:variable>
        <section 
            xml:id="{translate($title,$badchars,'_')}" 
            xmlns="http://docbook.org/ns/docbook">
            <title><xsl:value-of select="$title"/></title>
            <xsl:apply-templates select="xhtml:div[@class = 'details']" mode="apiref"/>
            <resources 
                xmlns="http://wadl.dev.java.net/2009/02">    
                <xsl:apply-templates select="xhtml:section[tokenize(@class, ' ') = 'resource']" mode="apiref"/>
            </resources>
        </section>
    </xsl:template>
    
    <xsl:template match="xhtml:div[@class = 'details']" mode="apiref">
        <xsl:apply-templates mode="apiref"/>
    </xsl:template>
    
    <xsl:template match="xhtml:p" mode="apiref">
        <para xmlns="http://docbook.org/ns/docbook">
            <xsl:apply-templates mode="apiref"/>
        </para>
    </xsl:template>
    
    <xsl:template match="xhtml:section[tokenize(@class, ' ') = 'resource']" mode="apiref">
        <resource xmlns="http://wadl.dev.java.net/2009/02" href="{$wadlname}#{fn:clean-id(xhtml:hgroup/xhtml:a/@id)}"/>
    </xsl:template>

    <!--
     Each of these is a resource+method combo:   
        <section class="resource noActivity hasDescription">
     -->
   

    <xsl:template match="xhtml:section[tokenize(@class, ' ') = 'resource']">
        <xsl:variable name="path" select="normalize-space(xhtml:hgroup/xhtml:h2)"/>
        <xsl:variable name="header" select="normalize-space(xhtml:div[@class = 'content']/xhtml:section[@class='example']/xhtml:section[@class='code' and starts-with(@id,'generatedResourceCode')]/xhtml:section[@class = 'outgoingCall']/xhtml:pre[@class='outgoing outgoingHeaders'])"/>
        <xsl:variable name="response-body" select="xhtml:div[@class = 'content']/xhtml:section[@class='example']/xhtml:section[@class='code' and starts-with(@id,'generatedResourceCode')]/xhtml:section[@class = 'outgoingCall']/xhtml:pre[@class='outgoing']/xhtml:code/text()"/>
        <resource xmlns="http://wadl.dev.java.net/2009/02" path="{$path}" id="{fn:clean-id(xhtml:hgroup/xhtml:a/@id)}">
           <xsl:for-each select="tokenize($path,'/')">
                <xsl:if test="starts-with(.,'{')">
                    <param name="{translate(.,'{}','')}" style="template" required="true"/>
                </xsl:if>
           </xsl:for-each>
            
           <method name="{normalize-space(xhtml:hgroup/xhtml:h1/xhtml:span)}">
               <doc>
                   <xsl:copy-of select="xhtml:article/*"/>
               </doc>
               <request>
                   <!-- TODO: query params? -->
                   <xsl:apply-templates select="xhtml:div[@class = 'content']" mode="request"/>
               </request>
               <response status="{substring($header,1,3)}">
                   <xsl:if test="not(normalize-space($response-body) = '')">
                       <representation mediaType="application/json" element="noop">
                           <doc xml:lang="en">
                               <xsdxt:code>
                                   <xsl:copy-of select="$response-body"/>
                               </xsdxt:code>
                           </doc>
                       </representation>
                   </xsl:if>
               </response>
           </method> 
        </resource>
        
    </xsl:template>    
    
    <xsl:function name="fn:clean-id" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:value-of select="translate(normalize-space($id),'%','')"/>
    </xsl:function>
    
    <xsl:template match="xhtml:div[@class='content']" mode="request">
        <xsl:variable name="body">"body": "</xsl:variable>
        <xsl:variable name="request-info" select="normalize-space(xhtml:section[@class='example']/xhtml:section[@class='code' and starts-with(@id,'generatedResourceCode')]/xhtml:script)"/>

        <xsl:if test="not(substring-after($request-info,$body) = 'null')">
            <representation mediaType="application/json" element="noop" >
        <doc xml:lang="en">
            <xsdxt:code>        
        <xsl:call-template name="parse-body">
            <xsl:with-param name="body" select="substring-after($request-info, $body)"/>
            <xsl:with-param name="spaces"/>
        </xsl:call-template> 
            </xsdxt:code>
        </doc>
        </representation>
        </xsl:if>
    </xsl:template>
        
   <xsl:param name="indent"><xsl:text>    </xsl:text></xsl:param>
   
   <xsl:template name="parse-body">
       <xsl:param name="body"/>
       <xsl:param name="spaces"/>
       <xsl:variable name="ending">" };</xsl:variable>
       <xsl:choose>
           <xsl:when test="contains($body,'\n')">
               <xsl:variable name="content">
                   <xsl:call-template name="prepare-content">
                       <xsl:with-param name="content" select="substring-before($body,'\n')"/>
                   </xsl:call-template>
               </xsl:variable>
<xsl:value-of select="$spaces"/><xsl:value-of select="$content"/><xsl:text>    
</xsl:text>
<xsl:call-template name="parse-body">
    <xsl:with-param name="body" select="substring-after($body,'\n')"/>
    <xsl:with-param name="spaces">
        <xsl:choose>
            <xsl:when test="starts-with(normalize-space($content),'}')"><xsl:value-of select="substring-after($spaces,$indent)"/></xsl:when>
            <xsl:when test="ends-with(normalize-space($content),'{')"><xsl:value-of select="$spaces"/><xsl:value-of select="$indent"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$spaces"/></xsl:otherwise>
        </xsl:choose>
    </xsl:with-param>
</xsl:call-template>               
           </xsl:when>
           <xsl:otherwise>
            <xsl:choose>
<xsl:when test="ends-with(normalize-space($body),$ending)"><xsl:value-of select="substring-before($body,$ending)"/></xsl:when>
<xsl:otherwise><xsl:value-of select="$body"/></xsl:otherwise>                
            </xsl:choose>
           </xsl:otherwise>
       </xsl:choose>
   </xsl:template>     
    
    <xsl:template name="prepare-content">
        <xsl:param name="content"/>
        <!-- Here we remove escape characters from the Apiary source -->
        <!-- Ugh: Divide and conquor. This seems painfully inelegant. -->
        <xsl:variable name="first-test">^\\"(.*)</xsl:variable>   
        <xsl:variable name="first-replacement">"$1</xsl:variable>
        <xsl:variable name="second-test">(.*)\\",?$</xsl:variable> 
        <xsl:variable name="second-replacement">$1"</xsl:variable>
        <xsl:variable name="third-test">(.*)\\": \\"(.*)</xsl:variable>
        <xsl:variable name="third-replacement">$1" : "$2</xsl:variable>
        <xsl:variable name="fourth-test">(.*)\\": (.*)</xsl:variable>
        <xsl:variable name="fourth-replacement">$1": $2</xsl:variable>
        <xsl:variable name="first-pass" select="replace(normalize-space($content),$first-test,$first-replacement)"/>
        <xsl:variable name="second-pass" select="replace($first-pass,$second-test,$second-replacement)"/>
        <xsl:variable name="third-pass" select="replace($second-pass,$third-test, $third-replacement)"/>
        <xsl:variable name="fourth-pass" select="replace($third-pass,$fourth-test, $fourth-replacement)"/>
<xsl:value-of select="$fourth-pass"/>
    </xsl:template>
    
    

    
</xsl:stylesheet>