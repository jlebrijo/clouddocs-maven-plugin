<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:l="http://xproc.org/library"
  xmlns:classpath="http://docs.rackspace.com/api"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  name="main">
  
  <p:input port="source"/> 
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="classpath:/rackspace-library.xpl"/>
  
  <cx:message>
    <p:with-option name="message" select="'Entering xproc pipeline'"/>
  </cx:message>
  
  <l:validate-transform name="validate-pre-xinclude">
    <p:input port="schema" >
      <p:document href="classpath:/rng/rackbook.rng"/>
    </p:input>
  </l:validate-transform>
 
  <p:add-xml-base/>
  <p:xinclude fixup-xml-base="true"/>
  
  <cx:message>
    <p:with-option name="message" select="'Validating post-xinclude'"/>
  </cx:message>
  
  <l:validate-transform name="validate-post-xinclude">
    <p:input port="schema" >
      <p:document  href="classpath:/rng/rackbook.rng"/> 
    </p:input>
  </l:validate-transform>
  
  <l:normalize-wadls name="normalize"/>
      
  <p:xslt name="process-embedded-wadl">
    <p:input port="source"> 
      <p:pipe step="normalize" port="result"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:document href="classpath:/cloud/apipage/process-embedded-wadl-apipage.xsl"/>
    </p:input>
    <p:input port="parameters" >
      <p:empty/>
    </p:input>
  </p:xslt>
  
<!--  <l:xhtml2docbook name="xhtml2docbook"/>   -->
  
 <!--
  <l:programlisting-keep-together name="programlisting-keep-together"/>
  -->
  
  <p:xslt name="docbook2apipage">
    <p:input port="source"> 
      <p:pipe step="process-embedded-wadl" port="result"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet
          xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
          xmlns:xhtml="http://www.w3.org/1999/xhtml"
          xmlns:wadl="http://wadl.dev.java.net/2009/02"
          xmlns:rax="http://docs.rackspace.com/api"
          xmlns:d="http://docbook.org/ns/docbook"
          xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0" 
          xmlns="http://www.w3.org/1999/xhtml"
          exclude-result-prefixes="xhtml xsdxt rax d" version="2.0">
          
          <xsl:character-map name="comment">
            <xsl:output-character character="«" string="&lt;"/>   
            <xsl:output-character character="»" string="&gt;"/>
            <xsl:output-character character="§" string='"'/>
          </xsl:character-map>
          
          <xsl:output 
            method="xhtml"
             doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
             doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
             use-character-maps="comment"
          indent="no"/>
          
          <xsl:param name="wadl.norequest.msg"><p class="nobody">This operation does not require a request body.</p></xsl:param>
          <xsl:param name="wadl.noresponse.msg"><p class="nobody">This operation does not return a response body.</p></xsl:param>
          <xsl:param name="wadl.noreqresp.msg"><p class="nobody">This operation does not require a request body and does not return a response body.</p></xsl:param>
          
          <xsl:template match="node() | @*">
            <xsl:copy>
              <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
          </xsl:template>
          
          <xsl:template match="wadl:method" mode="processDetailsBtn">
            <xsl:variable name="id" select="generate-id()"/>
            processADetailBtn(theText,'<xsl:value-of select="$id"/>_btn','\<xsl:comment><xsl:value-of select="$id"/>_btn_section START</xsl:comment>','\<xsl:comment><xsl:value-of select="$id"/>_btn_section END</xsl:comment>','<xsl:value-of select="$id"/>');           
            <xsl:if test="wadl:response/wadl:representation[ends-with(@mediaType,'/xml')]/wadl:doc/d:example and wadl:response/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example">
              processSelection(theText,'\<xsl:comment><xsl:value-of select="$id"/>_req_xml_selection START</xsl:comment>','\<xsl:comment><xsl:value-of select="$id"/>_req_xml_selection END</xsl:comment>','<xsl:value-of select="$id"/>','<xsl:value-of select="$id"/>_req_xml');
            </xsl:if>
            <xsl:if test="wadl:request/wadl:representation[ends-with(@mediaType,'/xml')]/wadl:doc/d:example and wadl:request/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example">
            processSelection(theText,'\<xsl:comment><xsl:value-of select="$id"/>_resp_xml_selection START</xsl:comment>','\<xsl:comment><xsl:value-of select="$id"/>_resp_xml_selection END</xsl:comment>','<xsl:value-of select="$id"/>','<xsl:value-of select="$id"/>_resp_xml');
            </xsl:if>
          </xsl:template>
          
          <xsl:template match="wadl:method" mode="setSectionsNSelections">
            <xsl:variable name="id" select="generate-id()"/>
            
            $("#<xsl:value-of select="$id"/>").hide();  
            <xsl:if test="wadl:response/wadl:representation[ends-with(@mediaType,'/xml')]/wadl:doc/d:example and wadl:response/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example">
            $("#<xsl:value-of select="$id"/>_resp_select").val("json");
            $("#<xsl:value-of select="$id"/>_resp_xml").hide();
            </xsl:if>
            <xsl:if test="wadl:request/wadl:representation[ends-with(@mediaType,'/xml')]/wadl:doc/d:example and wadl:request/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example">
            $("#<xsl:value-of select="$id"/>_req_select").val("json");
            $("#<xsl:value-of select="$id"/>_req_xml").hide();
            </xsl:if>
          </xsl:template>
          
          <xsl:template match="wadl:method" mode="showSelected">
            <xsl:variable name="id" select="generate-id()"/>
            <xsl:if test="position() != 1">else </xsl:if> if(selectorId=='<xsl:value-of select="$id"/>_req_select'){         
            <xsl:if test="wadl:request/wadl:representation[ends-with(@mediaType,'/xml')]/wadl:doc/d:example and wadl:request/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example">
                if(optionId=='xml'){
                  $("#<xsl:value-of select="$id"/>_req_json").hide();
                  $("#<xsl:value-of select="$id"/>_req_xml").show();
                }else{
                  $("#<xsl:value-of select="$id"/>_req_xml").hide();
                  $("#<xsl:value-of select="$id"/>_req_json").show();                     
              }</xsl:if>
            } <xsl:if test="wadl:response/wadl:representation[ends-with(@mediaType,'/xml')]/wadl:doc/d:example and wadl:response/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example"> else </xsl:if><xsl:if test="wadl:response/wadl:representation[ends-with(@mediaType,'/xml')]/wadl:doc and wadl:response/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc">if(selectorId=='<xsl:value-of select="$id"/>_resp_select'){
                if(optionId=='xml'){
                 $("#<xsl:value-of select="$id"/>_resp_json").hide();
                 $("#<xsl:value-of select="$id"/>_resp_xml").show();
                }else{
                 $("#<xsl:value-of select="$id"/>_resp_xml").hide();
                 $("#<xsl:value-of select="$id"/>_resp_json").show();                     
               }
              }
                 </xsl:if>
          </xsl:template>
          
          <xsl:template match="d:book">
            <html>
              <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
                <title>OpenStack API Documentation</title>
                <link rel="stylesheet" href="apiref/css/bootstrap.min.css"/>
                <!-- OpenStack Specific CSS -->
                <link rel="stylesheet" href="apiref/css/bootstrap-screen.css" type="text/css" media="screen, projection"/>
                <link rel="stylesheet" href="apiref/css/main.css" type="text/css" media="screen, projection, print"/>
                <script  type="text/javascript">
                  var _gaq = _gaq || [];
                  _gaq.push(['_setAccount', 'UA-17511903-8']);
                  _gaq.push(['_trackPageview']);
                  
                  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
                </script>
                <script type="text/javascript" src="apiref/js/main.js"><xsl:comment/></script>
                <script type="text/javascript">
                  <!-- TODO: Write out vars from main here -->

function processDetailsBtn(theText){
  <xsl:apply-templates select="//wadl:method" mode="processDetailsBtn"/>
}
                    
function setSectionsNSelections(){
  <xsl:apply-templates select="//wadl:method" mode="setSectionsNSelections"/>
}

function showSelected(selectorId, optionId){
  <xsl:apply-templates select="//wadl:method" mode="showSelected"/>
}                
                </script>
                <script type="text/javascript" src="apiref/js/jquery-1.2.6.min.js"><xsl:comment/></script>
              </head>
              <body>
                <form action="#">
                  <div id="wrapper">
                    <div class="container">
                      <div id="header">
                        <div class="span-5">
                          <h1 id="logo"><a href="/">Open Stack</a></h1>
                        </div>
                        <div class="span-19 last">
                          <div id="navigation">
                            <ul id="Menu1">					   		  
                              <li><a href="http://www.openstack.org" title="Go to the Home page">Home</a></li>		  
                              <li><a href="http://www.openstack.org/projects" title="Go to the OpenStack Projects page" class="link">Projects</a></li>		  
                              <li><a href="http://www.openstack.org/user-stories" title="Go to the OpenStack user stories page" class="link">User Stories</a></li>
                              <li><a href="http://www.openstack.org/community" title="Go to the Community page" class="link">Community</a></li>
                              <li><a href="http://www.openstack.org/blog" title="Go to the OpenStack Blog">Blog</a></li>
                              <li><a href="http://wiki.openstack.org/" title="Go to the OpenStack Wiki">Wiki</a></li>
                              <li><a href="http://docs.openstack.org/" title="Go to OpenStack Documentation"  class="current">Documentation</a></li>
                            </ul>
                          </div>			
                        </div>
                      </div>
                    </div>
                    <div id="body">
                      <p>&#160;</p>
                      <p>&#160;</p>
                      <xsl:apply-templates/>
                      
                      <div class="container">
                        <div id="footer">
                          <hr/>
                          <p>The OpenStack project is provided under the Apache 2.0 license.</p>
                        </div>
                      </div>
                      <div id="thebottom">&#x200B;</div>
                    </div>
                 
                  <div id="rightColumn">
                    <div id="pageSearcher">&#160;</div>
                  </div>
                  </div>
                  <div class="clear">&#160;</div>
                </form>
                 <script type="text/javascript" src="apiref/js/end.js">&#160;</script>
              </body>
            </html>
          </xsl:template>
          
          <xsl:template match="d:preface|d:chapter">
            <div class="container">
              <h2><xsl:value-of select="d:title"/></h2>
              <xsl:apply-templates/>
            </div>
          </xsl:template>

          <xsl:template match="d:section">
            <div>
              <h3><xsl:value-of select="d:title"/></h3>
              <xsl:apply-templates select="d:*"/>
              <xsl:apply-templates select=".//wadl:method"/>
            </div>
          </xsl:template>
          
          <xsl:template match="wadl:method">
            <xsl:variable name="id"><xsl:value-of select="generate-id()"/></xsl:variable>
            <xsl:variable name="skipNoRequestTextN">0</xsl:variable>
            <xsl:variable name="skipNoRequestText" select="boolean(number($skipNoRequestTextN))"/>
            <xsl:variable name="skipNoResponseTextN">0</xsl:variable>
            <xsl:variable name="skipNoResponseText" select="boolean(number($skipNoResponseTextN))"/>
            <div class="row {$id}">
              <div class="span1">
                <span class="label success"><xsl:value-of select="@name"/></span>
              </div>
              <div class="span5">
                <xsl:value-of select="ancestor::wadl:resource/@path"/>
              </div>
              <div class="span6">
                <xsl:choose>
                  <xsl:when test="wadl:doc//d:*[@role = 'shortdesc'] or wadl:doc//xhtml:*[@class = 'shortdesc']">
                    <xsl:apply-templates select="
                      wadl:doc/xhtml:p[@class='shortdesc']|
                      wadl:doc/d:para[@role = 'shortdesc']|
                      wadl:doc//xhtml:span[@class='shortdesc']|
                      wadl:doc//d:phrase[@role = 'shortdesc']            
                      "/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates select="
                      wadl:doc/xhtml:*|
                      wadl:doc/d:*|
                      wadl:doc/text()            
                      "/>
                  </xsl:otherwise>
                </xsl:choose>&#160;
              </div>
              <div class="span1">
                <a href="#" class="btn small info" id="{$id}_btn" onclick="toggleDetailsBtn(event,'{$id}_btn','{$id}','{$id}', '{concat(ancestor::wadl:resource/@path,'-',@name)}');">detail</a> 
              </div>              
            </div><xsl:comment> row </xsl:comment><xsl:text>
            </xsl:text>
            <div class="apidetail span16" id="{$id}">
              <xsl:comment> Do not edit or remove the next comment </xsl:comment><xsl:text>
            </xsl:text>
              <xsl:comment><xsl:value-of select="concat($id,'_btn_section START')"/></xsl:comment><xsl:text>
            </xsl:text>
              <div class="row">
                <!-- Description of method -->
                <xsl:if test="wadl:doc//d:*[@role = 'shortdesc'] or wadl:doc//xhtml:*[@class='shortdesc']">
                 <xsl:apply-templates
                    select="wadl:doc/d:*[not(@role = 'shortdesc')]|wadl:doc/xhtml:*[not(@role = 'shortdesc')]"/>
                </xsl:if>
              </div>
              <div class="row">
                <div class="span16">
                  <!-- Don't output if there are no params -->
                  <xsl:if test="./wadl:request//wadl:param or parent::wadl:resource/wadl:param">
                    <b>Request parameters</b>
                    <table class="zebra-striped">
                      <thead>
                        <tr>
                          <th>Parameter</th>
                          <th>Description</th>
                        </tr>
                      </thead>
                      <tbody>
                        <xsl:apply-templates select="./wadl:request//wadl:param|parent::wadl:resource/wadl:param" mode="param2tr">
                          <!-- Add templates to handle wadl:params -->
                          <xsl:with-param name="id" select="$id"/>
                        </xsl:apply-templates>
                      </tbody>
                    </table>
                  </xsl:if>
                  
                  
                  <!-- Don't output if there are no params -->
                  <xsl:if test="./wadl:response//wadl:param">
                    <b>Response parameters</b>
                    <table class="zebra-striped">
                      <thead>
                        <tr>
                          <th>Parameter</th>
                          <th>Description</th>
                        </tr>
                      </thead>
                      <tbody>
                        <xsl:apply-templates select="./wadl:response//wadl:param" mode="param2tr">
                          <!-- Add templates to handle wadl:params -->
                          <xsl:with-param name="id" select="$id"/>
                        </xsl:apply-templates>
                      </tbody>
                    </table>
                  </xsl:if>
                  

                </div>
              </div>
              <!-- Examples -->
              <xsl:choose>
                <xsl:when
                  test="wadl:request/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc/d:example 
                        and wadl:request/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example">
                  <select id="{$id}_req_select"
                    onchange="toggleSelection('{$id}_req_select','{concat(ancestor::wadl:resource/@path,'-',@name)}');">
                    <option value="xml" selected="selected">Request XML</option>
                    <option value="json">Request JSON</option>
                  </select><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the next comment </xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment><xsl:value-of select="concat($id,'_req_xml_selection START')"/></xsl:comment><xsl:text>                    
                  </xsl:text>
                  <div class="example" id="{concat($id,'_req_xml')}">
                    <xsl:apply-templates select="wadl:request/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc/d:example"/>
                  </div>
                  <xsl:comment><xsl:value-of select="concat($id,'_req_xml_selection END')"/></xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the previous comment </xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the next comment </xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment><xsl:value-of select="concat($id,'_req_json_selection START')"/></xsl:comment><xsl:text>                    
                  </xsl:text>
                  <div class="example" id="{concat($id,'_req_json')}">
                    <xsl:apply-templates select="wadl:request/wadl:representation[ends-with(@mediaType,'/json') ]/wadl:doc/d:example"/>
                  </div>
                  <xsl:comment><xsl:value-of select="concat($id,'_req_json_selection END')"/></xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the previous comment </xsl:comment><xsl:text>                    
                  </xsl:text>
                </xsl:when>
                <xsl:otherwise> 
                  <xsl:apply-templates select="wadl:request/wadl:representation/wadl:doc/d:example"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:choose>
                <xsl:when
                  test="wadl:response/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc/d:example 
                  and wadl:response/wadl:representation[ends-with(@mediaType,'/json')]/wadl:doc/d:example">
                  <select id="{$id}_resp_select"
                    onchange="toggleSelection('{$id}_resp_select');">
                    <option value="xml" selected="selected">Response XML</option>
                    <option value="json">Response JSON</option>
                  </select><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the next comment </xsl:comment>
                  <xsl:comment><xsl:value-of select="concat($id,'_resp_xml_selection START')"/></xsl:comment>
                  <div class="example" id="{concat($id,'_resp_xml')}">
                    <xsl:apply-templates select="wadl:response/wadl:representation[ends-with(@mediaType,'/xml') ]/wadl:doc/d:example"/>
                  </div><xsl:text>                    
                  </xsl:text>
                  <xsl:comment><xsl:value-of select="concat($id,'_resp_xml_selection END')"/></xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the previous comment </xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the next comment </xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment><xsl:value-of select="concat($id,'_resp_json_selection START')"/></xsl:comment><xsl:text>                    
                  </xsl:text>
                  <div class="example" id="{concat($id,'_resp_json')}">
                    <xsl:apply-templates select="wadl:response/wadl:representation[ends-with(@mediaType,'/json') ]/wadl:doc/d:example"/>
                  </div>
                  <xsl:comment><xsl:value-of select="concat($id,'_resp_json_selection END')"/></xsl:comment><xsl:text>                    
                  </xsl:text>
                  <xsl:comment> Do not delete or edit the previous comment </xsl:comment><xsl:text>                    
                  </xsl:text>
                </xsl:when>
                <xsl:otherwise> 
                  <xsl:apply-templates select="wadl:response/wadl:representation/wadl:doc/d:example"/>
                </xsl:otherwise>
              </xsl:choose>      
              
               <!-- we allow no response text and we dont have a 200 level response with a representation -->
                <xsl:choose>
                  <xsl:when test="not(wadl:request) and not(wadl:response[starts-with(normalize-space(@status),'2')]/wadl:representation)">
                    <xsl:copy-of select="$wadl.noreqresp.msg"/>
                  </xsl:when>
                  <xsl:when test="not(wadl:request)">
                    <xsl:copy-of select="$wadl.norequest.msg"/>
                  </xsl:when>
                  <xsl:when test="not(wadl:response[starts-with(normalize-space(@status),'2')]/wadl:representation)">
                    <xsl:copy-of select="$wadl.noresponse.msg"/>
                  </xsl:when>
                </xsl:choose>
                
            </div>
            <xsl:comment><xsl:value-of select="concat($id,'_btn_section END')"/></xsl:comment>
            <xsl:comment> Do not edit or remove the previous comment </xsl:comment>
          </xsl:template>

          <xsl:template match="wadl:doc|wadl:resource|wadl:link">
            <xsl:apply-templates/>
          </xsl:template>
          
          <xsl:template match="wadl:doc[parent::wadl:resource]"/>
          
          <xsl:template match="d:para">
            <p><xsl:apply-templates/></p>
          </xsl:template>
          
          <xsl:template match="d:link" xmlns:xlink="http://www.w3.org/1999/xlink">
            <a href="{@xlink:href}"><xsl:apply-templates/></a>
          </xsl:template>
          <xsl:template match="d:programlisting">
            <pre><xsl:apply-templates/></pre>
          </xsl:template>
          
          <xsl:template match="d:title[parent::d:chapter or parent::d:section or parent::d:book]|d:info|wadl:param"/>
          
          <xsl:template match="d:example/d:title">
            <b><xsl:apply-templates/></b>
          </xsl:template>
          
          <xsl:template match="d:example">
            <div class="example">
              <xsl:apply-templates/>
            </div>
          </xsl:template>
          
          <xsl:template match="d:itemizedlist">
            <ul>
              <xsl:apply-templates/>
            </ul>
          </xsl:template>
          
          <xsl:template match="d:orderedlist">
            <ol>
              <xsl:apply-templates/>
            </ol>
          </xsl:template>
          
          <xsl:template match="d:listitem">
            <li>
              <xsl:apply-templates/>
            </li>
          </xsl:template>
          
          <xsl:template match="wadl:param" mode="param2tr">
            <tr>
              <td><xsl:value-of select="@name"/><xsl:if test="not(@required = 'true') and not(@style = 'template') and not(@style = 'matrix')"> (Optional)</xsl:if></td>
              <td><xsl:apply-templates select="./wadl:doc/*|./wadl:doc/text()"/></td>
            </tr>
          </xsl:template>
          
          <xsl:template match="d:code"><code><xsl:apply-templates/></code></xsl:template>
          <xsl:template match="d:*">
            <xsl:copy>
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
          </xsl:template>
          
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="parameters" >
      <p:empty/>
    </p:input>
  </p:xslt>
  
<!--  <p:xslt name="foo">
    <p:input port="source"> 
      <p:pipe step="process-embedded-wadl" port="result"/> 
    </p:input> 
    <p:input port="stylesheet">
      <p:inline>
        
      </p:inline>
    </p:input>
  </p:xslt>-->
  
  <cx:message>
    <p:with-option name="message" select="'Exiting xproc pipeline'"/>
  </cx:message>
  
</p:declare-step>
