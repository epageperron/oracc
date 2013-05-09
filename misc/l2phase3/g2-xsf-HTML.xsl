<?xml version='1.0'?>

<!--

 XSL Stylesheet to produce XHTML version of XTF2 texts.

 Steve Tinney 2010-09-30, part of Oracc.

 v1.2.  Placed in the Public Domain.

-->

<xsl:stylesheet version="1.0" 
  xmlns:xpd="http://oracc.org/ns/xpd/1.0"
  xmlns:xtf="http://oracc.org/ns/xtf/1.0"
  xmlns:xcl="http://oracc.org/ns/xcl/1.0"
  xmlns:xff="http://oracc.org/ns/xff/1.0"
  xmlns:xtr="http://oracc.org/ns/xtr/1.0"
  xmlns:gdl="http://oracc.org/ns/gdl/1.0"
  xmlns:norm="http://oracc.org/ns/norm/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:md="http://oracc.org/ns/xmd/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xcl xff xtf gdl md xtr norm xpd"
  extension-element-prefixes="exsl">

<xsl:import href="xtf1-HTML.xsl"/>
<xsl:import href="g2-gdl-HTML.xsl"/>

<xsl:include href="html-standard.xsl"/>

<xsl:key name="lnodes" match="xcl:l" use="@ref"/>

<xsl:param name="project"/>
<xsl:param name="proofing-mode" select="false()"/>
<xsl:param name="standalone" select="true()"/>

<xsl:variable name="config-file" 
	      select="concat('/usr/local/oracc/xml/',$project,'/config.xml')"/>
<xsl:variable name="options-node"
	      select="document($config-file)//xpd:options"/>

<xsl:variable name="drop-allographs">
  <xsl:choose>
    <xsl:when test="$options-node/*[@name='render-allographs']/@value='drop'">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="char-rulings">
  <xsl:choose>
    <xsl:when test="$options-node/*[@name='render-rulings']/@value='char'">1</xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="label-style" select="$options-node/*[@name='render-labels']/@value"/>

<xsl:param name="render-lnum-periods" select="'no'"/>
<xsl:param name="render-surface-inits" select="'yes'"/>

<!--<xsl:include href="html-util.xsl"/>-->
<!--<xsl:include href="html-text.xsl"/>-->
<!--<xsl:include href="escape-quotes.xsl"/>-->

<xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="yes"/>
<!--<xsl:strip-space elements="*"/>-->

<!--
<xsl:variable name="lc" select="'abcdefghijklmnopqrstuvwxyzšŋ'"/>
<xsl:variable name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZŠŊ'"/>
 -->

<xsl:variable name="ruling-line" 
	      select="'─────────────────────────────'"/>
<!--<xsl:key name="wid" match="xcl:l" use="@ref"/>-->

<xsl:key name="label" match="xtf:object|xtf:surface|xtf:column|xtf:l" use="@label"/>

<xsl:variable name="PQ-id">
  <xsl:choose>
    <xsl:when test="not(/*/@xml:id) and /*/@ref">
      <xsl:value-of select="/*/@ref"/>
    </xsl:when>
    <xsl:when test="starts-with(/*/@xml:id,'s.')">
      <xsl:value-of select="substring-after(/*/@xml:id,'s.')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="/*/@xml:id"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:variable name="xmd" select="concat($PQ-id,'.xmd')"/>

<xsl:variable name="pubimg">
  <xsl:if test="document($xmd,/)/*/md:public_images='yes'">
    <xsl:choose>
      <xsl:when test="/*/md:images/md:img[@type='p']">
<!--      <xsl:when test="string-length(document($xmd,/)/*/md:photo_up) > 0">-->
        <xsl:text>**</xsl:text>
      </xsl:when>
      <xsl:when test="/*/md:images/md:img[@type='l']">
<!--      <xsl:when test="string-length(document($xmd,/)/*/md:lineart_up) > 0">-->
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:if>
</xsl:variable>

<!--
<xsl:template match="/">
  <xsl:copy-of select="$options-node"/>
</xsl:template>
-->

<!--
<xsl:template match="/|xtf:xtf">
  <xsl:apply-templates/>
</xsl:template>
-->

<xsl:template match="xtf:xtf">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="xtr:translation"/>

<xsl:template name="base-attr">
  <xsl:copy-of select="@n|@xml:id|@cols"/>
  <xsl:attribute name="xlabel">
    <xsl:value-of select="concat($pubimg,@n)"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="xtf:transliteration|xtf:composite|xtf:score">
  <xsl:message>processing <xsl:value-of select="local-name()"/></xsl:message>
  <xsl:choose>
    <xsl:when test="$standalone">
      <xsl:call-template name="make-html">
	<xsl:with-param name="title" select="'proofing'"/>
	<xsl:with-param name="webtype" select="'oraccscreen'"/>
	<xsl:with-param name="with-trailer" select="false()"/>
	<xsl:with-param name="standalone" select="true()"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="render-top-level"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="call-back">
  <h1 class="h2">
    <xsl:value-of select="@n"/>
  </h1>
  <xsl:choose>
    <xsl:when test="self::xtf:score">
      <xsl:variable name="pid" select="substring-after(/*/@xml:id,'s.')"/>
      <xsl:for-each select=".//xtf:lg">
	<table class="score-block">
	  <xsl:attribute name="xml:id"><xsl:value-of select="concat('sb.',/*/@xml:id,'.',position())"/></xsl:attribute>
	  <xsl:call-template name="base-attr"/>
	  <xsl:apply-templates/>
	</table>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="render-top-level"/>      
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="render-top-level">
  <xsl:message>processing <xsl:value-of select="local-name()"/></xsl:message>
  <div>
    <table class="{local-name(.)}">
      <xsl:call-template name="base-attr"/>
      <xsl:apply-templates/>
    </table>
    <xsl:message>#includes==<xsl:value-of select="count(xtf:include)"/>; self=<xsl:value-of select="local-name(.)"/></xsl:message>
    <xsl:apply-templates mode="print-include" select="xtf:include"/>
  </div>
</xsl:template>

<xsl:template match="atf">
  <pre>
    <xsl:value-of select="text()"/>
  </pre>
</xsl:template>

<xsl:template match="xtf:refunit">
  <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="xtf:score[not(@score-word='yes')]">
  <xsl:variable name="pid" select="substring-after(/*/@xml:id,'s.')"/>
  <score n="{@n}">
    <xsl:for-each select="xtf:lg">
      <table block-id="{@n}" class="score-block">
	<xsl:call-template name="base-attr"/>
	<xsl:apply-templates/>
      </table>
    </xsl:for-each>
  </score>
</xsl:template>

<xsl:template match="xtf:m">
  <tr class="h1">
    <td colspan="{ancestor::*[@cols][1]/@cols}">
      <span class="div">
	<xsl:choose>
	  <xsl:when test="@subtype = 'column'">
	    <xsl:value-of select="concat('(column ',text(),')')"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of 
		select="concat('(',@subtype|@division|text(),')')"/>
	  </xsl:otherwise>
	</xsl:choose>
      </span>
    </td>
  </tr>
</xsl:template>

<!--
<xsl:template match="xtf:score">
  <table class="score">
    <xsl:apply-templates/>
  </table>
</xsl:template>
-->

<xsl:template match="xtf:div">
  <xsl:if test="not(@type='segment') or not(@n='0')">
    <tr class="h1">
      <td colspan="{ancestor::*[@cols][1]/@cols}">
	<xsl:variable name="itype">
	  <xsl:call-template name="init-cap">
	    <xsl:with-param name="str" select="@subtype|@type"/>
	  </xsl:call-template>
	</xsl:variable>
	<xsl:variable name="n">
	  <xsl:if test="@n">
	    <xsl:value-of select="concat(' ',@n)"/>
	  </xsl:if>
	</xsl:variable>
	<span class="div"><xsl:value-of select="concat($itype,$n)"/></span>
      </td>
    </tr>
  </xsl:if>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="xtf:referto">
  <xsl:if test="preceding-sibling::*[1][not(local-name()='referto')]">
    <tr class="h1"><td colspan="{ancestor::*[@cols][1]/@cols}">See Also</td></tr>
  </xsl:if>
  <tr class="referto">
    <td colspan="{ancestor::*[@cols][1]/@cols}">
      <a href="concat('/',@ref,'.html')"><xsl:value-of select="@n"/></a>
    </td>
  </tr>
</xsl:template>

<xsl:template mode="print-include" match="xtf:include">
  <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="xtf:include"/>

<xsl:template match="xtf:includeXXX">
  <xsl:variable name="refproject">
    <xsl:choose>
      <xsl:when test="contains(@ref,'/')">
	<xsl:value-of select="substring-before(@ref,'/')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="refid">
    <xsl:choose>
      <xsl:when test="contains(@ref,'/')">
	<xsl:value-of select="substring-after(@ref,'/')"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@ref"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="basename">
    <xsl:text>/usr/local/oracc/bld/</xsl:text>
    <xsl:value-of select="$refproject"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="substring($refid,1,4)"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$refid"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="$refid"/>
  </xsl:variable>
  <xsl:variable name="refdoc">
    <xsl:value-of select="concat($basename,'.xtf')"/>
  </xsl:variable>
  <xsl:variable name="incdoc">
    <xsl:value-of select="concat($basename,'.txh')"/>
  </xsl:variable>
  <tr class="h2">
    <td colspan="{ancestor::*[@cols][1]/@cols}">
      <a href="javascript:showexemplar('{$refproject}','{$refid}','','')"><xsl:value-of select="@n"/></a>
    </td>
  </tr>
  <xsl:choose>
    <xsl:when test="@from">
      <xsl:variable name="f" select="@from"/>
      <xsl:variable name="start-id">
	<xsl:for-each select="document($refdoc)/*">
	  <xsl:value-of select="key('label',$f)/@xml:id"/>
	</xsl:for-each>
      </xsl:variable>
      <xsl:variable name="end-id">
	<xsl:choose>
	  <xsl:when test="@to">
	    <xsl:for-each select="document($refdoc)/*">
	      <xsl:value-of select="key('label',$f)/@xml:id"/>
	    </xsl:for-each>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:for-each select="document($refdoc)">
	      <xsl:for-each select="id($start-id)">
		<xsl:value-of select=".//xtf:l[last()]/@xml:id"/>
	      </xsl:for-each>
	    </xsl:for-each>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
<!--
      <xsl:message>refdoc: <xsl:value-of select="$refdoc"
      />; f: <xsl:value-of select="$f"
      />; start-id: <xsl:value-of select="$start-id"
      />; end-id: <xsl:value-of select="$end-id"/></xsl:message>
 -->
      <xsl:for-each select="document($incdoc)">
	<xsl:for-each select="id($start-id)">
	  <xsl:call-template name="copy-until">
	    <xsl:with-param name="next" select="."/>
	    <xsl:with-param name="end" select="$end-id"/>
	  </xsl:call-template>
	</xsl:for-each>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>including <xsl:value-of select="$incdoc"/></xsl:message>
      <xsl:copy-of select="document($incdoc)/*/*"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="copy-until">
  <xsl:param name="next"/>
  <xsl:param name="end"/>
  <xsl:copy-of select="$next"/>
<!--
  <xsl:message>next-id = <xsl:value-of select="$next/@xml:id"
  />; end-id = <xsl:value-of select="$end"/></xsl:message>
 -->
  <xsl:choose>
    <xsl:when test="$next/@xml:id = $end"/>
    <xsl:otherwise>
      <xsl:call-template name="copy-until">
	<xsl:with-param name="next" select="$next/following-sibling::*[1]"/>
	<xsl:with-param name="end" select="$end"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtf:object">
  <xsl:if test="not(@type='tablet') or @n">
    <xsl:variable name="hclass">
      <xsl:choose>
	<xsl:when test="@type='envelope'">hforce</xsl:when>
	<xsl:otherwise>h</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <tr class="{$hclass} object">
      <xsl:copy-of select="@xml:id"/>
      <td colspan="{ancestor::*[@cols][1]/@cols}">
	<span class="h2">
	  <xsl:variable name="object">
	    <xsl:choose>
	      <xsl:when test="@type='other'">
		<xsl:value-of select="@object"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="@type"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>	
	  <xsl:if test="not($object='tablet')">
	    <xsl:call-template name="init-cap">
              <xsl:with-param name="str" select="$object"/>
            </xsl:call-template>
	    <xsl:text> </xsl:text>
	  </xsl:if>
	  <xsl:choose>
	    <xsl:when test="@n">
	       <xsl:value-of select="@n"/>
	    </xsl:when>
            <xsl:when test="@face">
              <xsl:text> </xsl:text>
              <xsl:value-of select="@face"/>
            </xsl:when>
	    <xsl:when test="@type='other'"/>
	    <xsl:otherwise>
<!--
              <xsl:call-template name="init-cap">
		<xsl:with-param name="str" select="@type"/>
              </xsl:call-template>
 -->
            </xsl:otherwise>
	  </xsl:choose>    
	  <xsl:if test="@certain='n'">
            <xsl:text>?</xsl:text>
	  </xsl:if>
	</span>
      </td>
    </tr>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="xtf:l|xtf:lg/xtf:l">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtf:surface|xtf:sealing">
  <xsl:if test="ancestor::xtf:object[@type='tablet' or @type='envelope'] 
		or @face
		or @surface
		or self::xtf:sealing">
    <xsl:variable name="hclass">
      <xsl:choose>
	<xsl:when test="@type='seal'">hforce</xsl:when>
	<xsl:otherwise>h</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <tr class="{$hclass} {local-name(.)}">
      <xsl:copy-of select="@xml:id"/>
      <td colspan="{ancestor::*[@cols][1]/@cols}">
	<span class="h2">
	  <xsl:choose>
	    <xsl:when test="not(local-name()='surface')">
	      <xsl:call-template name="init-cap">
		<xsl:with-param name="str" select="local-name()"/>
	      </xsl:call-template>
	      <xsl:text> </xsl:text>
	    </xsl:when>
	    <xsl:when test="@type='seal'">
	      <xsl:call-template name="init-cap">
		<xsl:with-param name="str" select="@type"/>
	      </xsl:call-template>
	      <xsl:text> </xsl:text>
	    </xsl:when>
	  </xsl:choose>
	  <xsl:choose>
	    <xsl:when test="@n">
	      <xsl:value-of select="@n"/>
	    </xsl:when>
            <xsl:when test="@face">
              <xsl:text> </xsl:text>
              <xsl:value-of select="@face"/>
            </xsl:when>
	    <xsl:otherwise>
	      <xsl:choose>
		<xsl:when test="@type='obverse' or @type='reverse'">
		  <xsl:if test="ancestor::xtf:object[@type='tablet']">
		    <xsl:call-template name="init-cap">
		      <xsl:with-param name="str" select="@type"/>
		    </xsl:call-template>
		  </xsl:if>
		</xsl:when>
		<xsl:when test="@type='surface'">
		  <xsl:call-template name="init-cap">
		    <xsl:with-param name="str" select="@surface"/>
		  </xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:call-template name="init-cap">
		    <xsl:with-param name="str" select="@type"/>
		  </xsl:call-template>
		</xsl:otherwise>
	      </xsl:choose>
            </xsl:otherwise>
	  </xsl:choose>    
	  <xsl:if test="@certain='n'">
            <xsl:text>?</xsl:text>
	  </xsl:if>
	</span>
      </td>
    </tr>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="xtf:l|xtf:lg/xtf:l">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtf:column">
  <xsl:if test="not(@n = '0')">
    <tr class="h column">
      <xsl:copy-of select="@xml:id"/>
      <td colspan="{ancestor::*[@cols][1]/@cols}">
	<span class="h2">
	  <xsl:call-template name="init-cap">
            <xsl:with-param name="str" select="local-name()"/>
          </xsl:call-template>
	  <xsl:text> </xsl:text>
	  <xsl:variable name="n" 
			select="document('/usr/local/oracc/lib/config/label-info.xml')/*/*[@n=current()/@n]/@a"/>
	  <xsl:choose>
	    <xsl:when test="string-length($n) > 0">
	      <xsl:value-of select="$n"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="@n"/>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:if test="@primes"><xsl:value-of select="@primes"/></xsl:if>
	  <xsl:if test="@remark='y'"><xsl:text>!</xsl:text></xsl:if>
	  <xsl:if test="@certain='n'"><xsl:text>?</xsl:text></xsl:if>
	</span>
      </td>
    </tr>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="*[xtf:c]|xtf:lg/*[xtf:c]">
      <xsl:variable name="maxcols">
	<xsl:for-each select="*[xtf:c]|*/*[xtf:c]">
	  <xsl:sort select="count(xtf:c)" order="descending"/>
	  <xsl:if test="position() = 1">
	    <xsl:value-of select="count(xtf:c)"/>
	  </xsl:if>
	</xsl:for-each>
      </xsl:variable>
<!--      <xsl:message>$maxcols = <xsl:value-of select="$maxcols"/></xsl:message> -->
      <xsl:apply-templates>
	<xsl:with-param name="maxcols" select="$maxcols"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xtf:lg">
  <xsl:param name="maxcols" select="0"/>
  <xsl:apply-templates>
    <xsl:with-param name="maxcols" select="$maxcols"/>
  </xsl:apply-templates>
  <xsl:if test="self::xtf:lg and /xtf:score[not(@score-type='legacy')]">
    <tr class="score-spacer"><td> </td></tr>
  </xsl:if>
</xsl:template>

<xsl:template match="xtf:noncolumn">
  <tr class="noncolumn">
    <td colspan="{ancestor::*[@cols][1]/@cols}"><xsl:call-template name="do-non-c-or-l"/></td>
  </tr>
</xsl:template>

<xsl:template name="span-lnum">
  <span class="lnum">
    <xsl:if test="$render-surface-inits='yes'
		 and count(preceding-sibling::*) = 0">
      <xsl:if test="not(ancestor::xtf:surface/@implicit)">
	<xsl:variable name="surface" 
		      select="ancestor::xtf:surface/@label"/>
	<!-- FIXME: we need to load a map of surface
	     label names from the project to support localization 
	     also -->
	<xsl:choose>
	  <xsl:when test="$label-style='saa-style'">
	    <xsl:choose>
	      <xsl:when test="$surface='o'"/>
	      <xsl:when test="$surface='b.e.'">
		<xsl:text>b.e.</xsl:text>
		<xsl:text>&#xa0;</xsl:text>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$surface"/>
		<xsl:if test="not(starts-with(substring($surface,
			      string-length($surface)),'.'))">
		  <xsl:text>.</xsl:text>
		</xsl:if>
		<xsl:text>&#xa0;</xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="ancestor::xtf:surface/@label"/>
	    <xsl:text>&#xa0;</xsl:text>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
      <xsl:if test="not(ancestor::xtf:column/@implicit)">
	<xsl:variable name="numval" select="number(ancestor::xtf:column/@n)"/>
	<xsl:choose>
	  <xsl:when test="$label-style='saa-style'">
	    <xsl:number format="I" value="$numval"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:number format="i" value="$numval"/>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:text>&#xa0;</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@n">
      <xsl:value-of select="@n"/>
      <xsl:if test="$render-lnum-periods = 'yes'">
	<xsl:text>.</xsl:text>
      </xsl:if>
    </xsl:if>
  </span>
</xsl:template>

<xsl:template match="xtf:nonl|xtf:nonx">
  <xsl:variable name="class-val">
    <xsl:choose>
      <xsl:when test="/xtf:score[not(@score-type='legacy')]">
	<xsl:text>lnuml</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>lnum</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="xnonl-class">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1][self::xtf:nonl or self::xtf:nonx]">
	<xsl:choose>
	  <xsl:when test="following-sibling::*[1][self::xtf:nonl or self::xtf:nonx]">
	    <xsl:text>-medial</xsl:text>
	  </xsl:when>
	  <xsl:otherwise>-final</xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="following-sibling::*[1][self::xtf:nonl or self::xtf:nonx]">
	<xsl:text>-initial</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>
  <tr class="nonl{$xnonl-class}">
    <xsl:if test="@xml:id">
      <xsl:attribute name="xml:id">
        <xsl:value-of select="@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::*[1])">
	<td class="{$class-val}">
	  <span class="xlabel">
	    <xsl:value-of select="translate(ancestor-or-self::*[@label][1]/@label,
				  ' ','&#xa0;')"/>
	  </span>
	  <xsl:call-template name="span-lnum"/>
	</td>
      </xsl:when>
      <xsl:otherwise>
	<td class="nonlnum"/>
      </xsl:otherwise>
    </xsl:choose>
    <td colspan="{ancestor::*[@cols]/@cols}" class="nonlbody"><xsl:call-template name="do-non-c-or-l"/></td>
  </tr>
</xsl:template>

<xsl:template name="do-non-c-or-l">
  <span class="noncl">
    <xsl:choose>
      <xsl:when test="@strict=1">
	<xsl:if test="not(@state='ruling')">
	  <xsl:text> (</xsl:text>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="@scope='impression' and not(starts-with(.,'('))">
	    <xsl:value-of select="concat('impression of ',.)"/>
	  </xsl:when>
	  <xsl:when test="@state='ruling'">
	    <xsl:choose>
	      <xsl:when test="$char-rulings=1">
		<xsl:value-of select="$ruling-line"/>
		<xsl:if test="@flags">
		  <sup><xsl:value-of select="@flags"/></sup>
		</xsl:if>
	      </xsl:when>
	      <xsl:otherwise>
		<hr/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:when test="@extent='0' or @extent='n'">
	    <xsl:value-of select="@state"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:if test="@state='traces'">
	      <xsl:text>traces</xsl:text>
	      <xsl:if test="@extent"><xsl:text> of </xsl:text></xsl:if>
	    </xsl:if>
	    <xsl:if test="@extent and not(@scope='impression')">
	      <xsl:value-of select="@extent"/>
	      <xsl:text> </xsl:text>
	      <xsl:if test="@extent = 'rest' or @extent = 'start'">
		<xsl:text>of </xsl:text>
	      </xsl:if>
	    </xsl:if>
	    <xsl:if test="not(@state='seal') and not(@state='ruling') and @extent">
	      <xsl:value-of select="@scope"/>
	      <xsl:if test="@extent='n' or @extent>1"><xsl:text>s</xsl:text></xsl:if>
	      <xsl:if test="not(@state='traces')"><xsl:text> </xsl:text></xsl:if>
	    </xsl:if>
	    <xsl:if test="not(@state='traces')">
	      <xsl:value-of select="@state"/>
	    </xsl:if>
	    <xsl:if test="@ref">
	      <xsl:text> </xsl:text>
	      <xsl:value-of select="@ref"/>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:if test="not(@state='ruling')">
	  <xsl:text>)</xsl:text>
	</xsl:if>
      </xsl:when>
      <xsl:when test="@type='image'">
	<img src="/{ancestor::xtf:transliteration/@project}/images/{@ref}.png"/>
      </xsl:when>
      <xsl:when test="@state='other' and text()='SPACER'"/>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </span>
</xsl:template>

<xsl:template match="xtf:nong">
  <span class="nong">
    <xsl:choose>
      <xsl:when test="@type='broken'">
<!--
        <xsl:text> (</xsl:text>
        <xsl:value-of select="@extent"/>
        <xsl:text> signs broken)</xsl:text>
-->
         <xsl:text> [...] </xsl:text>
      </xsl:when>
      <xsl:when test="@type='maybe-broken'">
         <xsl:text> [(...)] </xsl:text>
      </xsl:when>
      <xsl:when test="@type='traces'">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@extent"/>
        <xsl:text> signs)</xsl:text>
      </xsl:when>
      <!--
	FIXME: does maybe-traces need to do the same extent handling as traces?
        -->
      <xsl:when test="@type='maybe-traces'">
        <xsl:text> (...) </xsl:text>
      </xsl:when>
      <xsl:when test="@type='gap'">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@extent"/>
        <xsl:text> signs)</xsl:text>
      </xsl:when>
      <xsl:when test="@type='other'">
        <xsl:text> (</xsl:text>
	<xsl:value-of select="text()"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="@type='seal'">
        <xsl:text> (seal </xsl:text>
        <xsl:value-of select="@ref"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="@type='newline'">
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message><xsl:value-of 
		select="/*/@xml:id"/>: NONG type not handled: <xsl:value-of 
			select="@type"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </span>
  <xsl:if test="@notemark">
    <xsl:call-template name="process-notes"/>
  </xsl:if>
</xsl:template>

<xsl:template match="xtf:l">
  <xsl:param name="maxcols" select="0"/>
  <xsl:variable name="href">
    <xsl:choose>
      <xsl:when test="/xtf:composite">
	<xsl:value-of select="/*/@xml:id"/>
	<xsl:text>_</xsl:text>
	<xsl:value-of select="@n"/>
	<xsl:text>.html</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="name">
    <xsl:if test="/xtf:transliteration">
      <xsl:value-of select="@xml:id"/>
    </xsl:if>
  </xsl:variable>
<!--
  <xsl:choose>
    <xsl:when test="xtf:mpx">
      <xsl:call-template name="format-line">
	<xsl:with-param name="lnode" select="xtf:mpx[1]"/>
   	<xsl:with-param name="href" select="$href"/>
   	<xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
 -->
      <xsl:call-template name="format-line">
	<xsl:with-param name="lnode" select="."/>
   	<xsl:with-param name="href" select="$href"/>
   	<xsl:with-param name="name" select="$name"/>
	<xsl:with-param name="maxcols" select="$maxcols"/>
      </xsl:call-template>
      <xsl:apply-templates mode="after-line" select="xtf:note"/>
<!--
    </xsl:otherwise>
  </xsl:choose>
 -->
</xsl:template>

<xsl:template name="format-line">
  <xsl:param name="href"/>
  <xsl:param name="lnode"/>
  <xsl:param name="name"/>
  <xsl:param name="maxcols"/>
  <xsl:for-each select="$lnode">
  <tr class="l">
    <!--NOTE: XHTML 1.0 DOES NOT USE XML:ID, this needs to be hacked on output
	for XHTML pages, but we keep to XML:ID here because the Context Engine
	uses the TXH files to return line context-->
    <xsl:variable name="lid">
      <xsl:choose>
	<xsl:when test="self::xtf:mpx">
	  <xsl:value-of select="../@xml:id"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@xml:id"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="label">
      <xsl:choose>
	<xsl:when test="self::xtf:mpx">
	  <xsl:value-of select="../@label"/>
	</xsl:when>
	<xsl:when test="not(@label)">
	  <xsl:value-of select="@n"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="translate(@label,' ','&#xa0;')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="lnum">
      <xsl:choose>
	<xsl:when test="self::xtf:mpx">
	  <xsl:value-of select="../@n"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="@n"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($lid)>0">
      <xsl:attribute name="xml:id">
        <xsl:value-of select="$lid"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:attribute name="label">
      <xsl:value-of select="concat(/*/@n,', ',$label)"/>
    </xsl:attribute>
    <xsl:if test="count(preceding::xtf:l) > 5">
      <xsl:attribute name="cid">
	<xsl:value-of select="preceding::xtf:l[5]/@xml:id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="string-length($href) > 0">
 	<xsl:choose>
	  <xsl:when test="xtf:c">
	    <xsl:call-template name="td-lnum">
	      <xsl:with-param name="label" select="$label"/>
	    </xsl:call-template>
	    <xsl:apply-templates>
	      <xsl:with-param name="maxcols" select="$maxcols"/>
	      <xsl:with-param name="proofing-mode" select="$proofing-mode"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:choose>
	      <xsl:when test="$proofing-mode">
		<td>
		  <table class="proof">
		    <tr>
		      <xsl:call-template name="td-lnum">
			<xsl:with-param name="label" select="$label"/>
		      </xsl:call-template>
		      <xsl:for-each select="*">
			<td>
			  <xsl:apply-templates select="."/>
			</td>
		      </xsl:for-each>
		    </tr>
		    <tr>
		      <td>&#xa0;</td>
		      <xsl:for-each select="*">
			<xsl:choose>
			  <xsl:when test="self::gdl:w">
			    <xsl:variable name="lnodes" select="key('lnodes',@xml:id)"/>
			    <td>
			      <xsl:choose>
				<xsl:when test="starts-with($lnodes/@inst,'%')">
				  <xsl:value-of select="substring-after($lnodes/@inst,':')"/>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:value-of select="$lnodes/@inst"/>
				</xsl:otherwise>
			      </xsl:choose>
			    </td>
			  </xsl:when>
			  <xsl:otherwise>
			    <td>&#xa0;</td>
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:for-each>
		    </tr>
		    <tr>
		      <td>&#xa0;</td>
		      <xsl:for-each select="*">
			<xsl:choose>
			  <xsl:when test="self::gdl:w">
			    <xsl:variable name="lnodes" select="key('lnodes',@xml:id)"/>
			    <td>
			      <xsl:choose>
				<xsl:when test="$lnodes/*[1]/@morph2">
				  <xsl:value-of select="$lnodes/*[1]/@morph"/>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:value-of select="$lnodes/*[1]/@norm"/>
				</xsl:otherwise>
			      </xsl:choose>
			    </td>
			  </xsl:when>
			  <xsl:otherwise>
			    <td>&#xa0;</td>
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:for-each>
		    </tr>
		    <xsl:if test="key('lnodes',*/@xml:id)/*[1]/@morph2">
		      <tr>
			<td>&#xa0;</td>
			<xsl:for-each select="*">
			  <xsl:choose>
			    <xsl:when test="self::gdl:w">
			      <xsl:variable name="lnodes" select="key('lnodes',@xml:id)"/>
			      <td><xsl:value-of select="$lnodes/*[1]/@morph2"/></td>
			    </xsl:when>
			    <xsl:otherwise>
			      <td>&#xa0;</td>
			    </xsl:otherwise>
			  </xsl:choose>
			</xsl:for-each>
		      </tr>
		    </xsl:if>
		  </table>
		</td>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:call-template name="td-lnum">
		  <xsl:with-param name="label" select="$label"/>
		</xsl:call-template>
		<td>
		  <xsl:apply-templates/>
		</td>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- this block is used for P-texts -->
      <xsl:when test="string-length($name) > 0">
	<xsl:call-template name="td-lnum">
	  <xsl:with-param name="label" select="$label"/>
	</xsl:call-template>
	<xsl:choose>
	  <xsl:when test="xtf:c">
 	    <xsl:apply-templates>
	      <xsl:with-param name="maxcols" select="$maxcols"/>
	      <xsl:with-param name="proofing-mode" select="$proofing-mode"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
 	    <td class="tlit">
	      <xsl:if test="@spanall='1'">
		<xsl:attribute name="colspan">
		  <xsl:value-of select="ancestor-or-self::*[@cols][1]/@cols"/>
		</xsl:attribute>
	      </xsl:if>
	      <p class="tt">
		<xsl:apply-templates>
		  <xsl:with-param name="proofing-mode" select="$proofing-mode"/>
		</xsl:apply-templates>
	      </p>
	    </td>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:when test="/xtf:score">
	<xsl:call-template name="td-lnum">
	  <xsl:with-param name="label" select="$label"/>
	</xsl:call-template>
 	<xsl:choose>
	  <xsl:when test="xtf:c">
 	    <xsl:apply-templates>
	      <xsl:with-param name="maxcols" select="$maxcols"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
 	    <td><xsl:apply-templates/></td>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="td-lnum">
	  <xsl:with-param name="label" select="$label"/>
	</xsl:call-template>
 	<xsl:choose>
	  <xsl:when test="xtf:c">
 	    <xsl:apply-templates>
	      <xsl:with-param name="maxcols" select="$maxcols"/>
	    </xsl:apply-templates>
	  </xsl:when>
	  <xsl:otherwise>
 	    <td><xsl:apply-templates/></td>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </tr>
  </xsl:for-each>
</xsl:template>

<xsl:template name="td-lnum">
  <xsl:param name="label"/>
  <xsl:variable name="class-val">
    <xsl:choose>
      <xsl:when test="/xtf:score[not(@score-type='legacy')]">
	<xsl:text>lnuml</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:text>lnum</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <td class="{$class-val}">
    <xsl:choose>
      <xsl:when test="@xml:id">
	<xsl:if test="not(@silent) or not(@silent='1')">
	  <a name="a.{@xml:id}">
	    <span class="xlabel">
	      <xsl:value-of select="$label"/>
	    </span>
	    <xsl:call-template name="span-lnum"/>
	  </a>
	</xsl:if>
      </xsl:when>
      <!-- This is an =: line -->
      <xsl:otherwise/>
    </xsl:choose>
  </td>
</xsl:template>

<xsl:template match="xtf:mpx"/>

<!-- Is there even an xtf:e any more?  
     
     Nowadays this code is to handle score matrix|synopsis parsed -->
<xsl:template match="xtf:e|xtf:v">
  <xsl:variable name="maxcols">
    <xsl:for-each select="*[xtf:c]|*/*[xtf:c]">
      <xsl:sort select="count(xtf:c)" order="descending"/>
      <xsl:if test="position() = 1">
	<xsl:value-of select="count(xtf:c)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="href">
    <xsl:choose>
      <xsl:when test="/xtf:score">
	<xsl:value-of select="@p"/>
	<xsl:text>.html#</xsl:text>
	<xsl:value-of select="@plid"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <tr class="e">
    <xsl:choose>
      <xsl:when test="string-length($href) > 0">
	<xsl:choose>
	  <xsl:when test="not(/xtf:score[@score-type='legacy'])">
	    <td>
	      <span class="lnuml enum-newscore">
		<xsl:choose>
		  <xsl:when test="@varnum">
<!--		    <a href="javascript:showexemplar('{@p}','{@hlid}')"> -->
		      <xsl:value-of select="translate(@varnum,'_','&#xa0;')"/>
<!--		    </a>		-->
		  </xsl:when>
		  <xsl:otherwise>
		    <a href="javascript:showexemplar('{@p}','{@hlid}')">
		      <xsl:value-of select="concat(@n,' ',@l)"/>
		    </a>
		  </xsl:otherwise>
		</xsl:choose>
	      </span>	    
	    </td>
	  </xsl:when>
	  <xsl:otherwise>
	    <td> </td>
	  </xsl:otherwise>
	</xsl:choose>
        <xsl:choose>
          <xsl:when test="xtf:c">
            <xsl:apply-templates>
	      <xsl:with-param name="maxcols" select="$maxcols"/>
	    </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <td><xsl:apply-templates/></td>
          </xsl:otherwise>
        </xsl:choose>
	<xsl:if test="/xtf:score[@score-type='legacy']">
	  <td>
	    <span class="enum">
	      <xsl:choose>
		<xsl:when test="@varnum">
		  <a href="javascript:showexemplar('{@p}','{@hlid}')">
		    <xsl:value-of select="@varnum"/>
		  </a>		
		</xsl:when>
		<xsl:otherwise>
		  <a href="javascript:showexemplar('{@p}','{@hlid}')">
		    <xsl:value-of select="concat(@n,' ',@l)"/>
		  </a>
		</xsl:otherwise>
	      </xsl:choose>
	    </span>	    
	  </td>
	</xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <td><span class="enum"><xsl:value-of select="concat(@n,' ',@l)"
	  	/><xsl:text>. </xsl:text></span></td>	
        <xsl:choose>
    	  <xsl:when test="xtf:c">
            <xsl:apply-templates>
	      <xsl:with-param name="maxcols" select="$maxcols"/>
	    </xsl:apply-templates>
 	  </xsl:when>
	  <xsl:otherwise>
            <td><xsl:apply-templates/></td>
	  </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </tr>
</xsl:template>

<xsl:template name="format-e">
</xsl:template>

<!--
<xsl:template match="xtf:n">
  <span class="n"><xsl:apply-templates/></span>
  <xsl:if test="following-sibling::*">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>
-->

<xsl:template match="xtf:c">
  <xsl:param name="maxcols"/>
  <td class="c">
    <xsl:if test="position() = last()">
      <xsl:variable name="colspan" 
 	 	  select="$maxcols - (1+count(preceding-sibling::xtf:c))"/>
      <xsl:if test="$colspan > 0">
	<xsl:attribute name="colspan">
	  <xsl:value-of select="1+$colspan"/>
	</xsl:attribute>
      </xsl:if>
    </xsl:if>    
  <p><xsl:apply-templates/></p>
  </td>
</xsl:template>

<xsl:template match="xtf:f">
  <xsl:choose>
    <xsl:when test="@type='sv'">
      <xsl:if test="*">
	<xsl:apply-templates select=".//gdl:nonw"/>
	<span class="{@type}">
	  <xsl:text>&#xa0;[[</xsl:text>
	  <xsl:apply-templates select="*[not(self::gdl:nonw)]">
	    <xsl:with-param name="allow-space" select="false()"/>
	  </xsl:apply-templates>
	  <xsl:text>]]</xsl:text>
	</span>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <span class="{@type}">
	<xsl:apply-templates/>
      </span>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="following-sibling::*">
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="norm:w">
  <xsl:param name="allow-space" select="true()"/>
  <xsl:call-template name="gdl-w">
    <xsl:with-param name="allow-space" select="$allow-space"/>
  </xsl:call-template>
</xsl:template>

<xsl:template mode="form" match="xtf:g">
  <xsl:if test="not(@sign='ed.removed')">
    <xsl:if test="@gloss"><xsl:text>{</xsl:text></xsl:if>
    <xsl:choose>
      <xsl:when test="@role='logogram'">
	<xsl:call-template name="render-grapheme">
          <xsl:with-param name="g" select="."/>
          <xsl:with-param name="c" select="'logogram'"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:call-template name="render-grapheme">
          <xsl:with-param name="g" select="."/>
          <xsl:with-param name="c" select="@nametype"/>
	</xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@gloss"><xsl:text>}</xsl:text></xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="xtf:gg">
  <xsl:for-each select="*">
    <xsl:apply-templates select="."/>
    <xsl:if test="not(position() = last())
		and not(@gloss='pre')
		and not(following-sibling::*[1][@gloss='post'])">
      <xsl:text>.</xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template mode="form" match="xtf:cg|xtf:gg|xtf:nong|xtf:cg.g|xtf:cg.gg">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template mode="form" match="xtf:igg">
  <xsl:apply-templates mode="form" select="*[1]"/>
</xsl:template>

<xsl:template mode="form" match="xtf:gloss" />

<xsl:template match="xtf:igg">
  <xsl:apply-templates mode="igg-interp" select="*[1]"/>

  <xsl:text>(</xsl:text>
    <xsl:apply-templates mode="igg-verbatim" select="*[2]"/>
  <xsl:text>)</xsl:text>

  <xsl:for-each select="descendant::xtf:g[position()=last()]">
    <xsl:variable name="prev-g" 
	        select="preceding::xtf:g[1][ancestor::xtf:l/@xml:id 
					  = current()/ancestor::xtf:l/@xml:id]"/>
    <xsl:variable name="next-g" 
	        select="following::xtf:g[1][ancestor::xtf:l/@xml:id 
					  = current()/ancestor::xtf:l/@xml:id]"/>
    <xsl:call-template name="close-sign">
      <xsl:with-param name="next-g" select="$next-g"/>
    </xsl:call-template>
    <xsl:call-template name="close-breakage">
      <xsl:with-param name="next-g" select="$next-g"/>
    </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<xsl:template mode="igg-interp" match="xtf:gg">
  <xsl:for-each select="*">
    <xsl:apply-templates select="."/>
    <xsl:if test="not(position() = last())">
      <xsl:text>:</xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template mode="igg-verbatim" match="xtf:gg">
  <xsl:for-each select="*">
    <xsl:apply-templates select="."/>
    <xsl:if test="not(position() = last())">
      <xsl:text>&#xa0;</xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template mode="igg-verbatim" match="xtf:cg">
  <xsl:for-each select="*">
    <xsl:apply-templates select="."/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="xtf:cg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="xtf:cg.g">
  <xsl:call-template name="render-grapheme">
    <xsl:with-param name="g" select="."/>
    <xsl:with-param name="c" select="'signref'"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="xtf:cg.gg">
  <xsl:text>(</xsl:text>
  <xsl:for-each select="*">
    <xsl:apply-templates select="."/>
<!--
    <xsl:if test="not(position() = last())">
      <xsl:text>.</xsl:text>
    </xsl:if>
 -->
  </xsl:for-each>
  <xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="xtf:cg.rel">
  <xsl:choose>
    <xsl:when test="@c='adjacent'">
      <xsl:text>.</xsl:text>
    </xsl:when>
    <xsl:when test="@c='ligatured'">
      <xsl:text>+</xsl:text>
    </xsl:when>
    <xsl:when test="@c='times'">
      <xsl:text>×</xsl:text>
    </xsl:when>
    <xsl:when test="@c='over'">
      <xsl:text>&amp;</xsl:text>
    </xsl:when>
    <xsl:when test="@c='opposed'">
      <xsl:text>@</xsl:text>
    </xsl:when>
    <xsl:when test="@c='crossed'">
      <xsl:text>%</xsl:text>
    </xsl:when>
    <xsl:when test="@c='or'">
      <xsl:text>/</xsl:text>
    </xsl:when>
    <xsl:when test="@c='exorder'">
      <xsl:text>:</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>unknown cg.rel type '<xsl:value-of select="@c"/>'</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="igg-interp" match="xtf:g|xtf:cg.g">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template mode="igg-verbatim" match="xtf:g|xtf:cg.g">
  <xsl:apply-templates select=".">
    <xsl:with-param name="igg-verb" select="'yes'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="xtf:gloss|gdl:gloss">
  <xsl:if test="*|text()">
    <sup class="gloss">
      <xsl:apply-templates/>
    </sup>
  </xsl:if>
</xsl:template>

<xsl:template match="xtf:surro">
  <xsl:apply-templates select="*[1]"/>
  <xsl:text>&lt;(</xsl:text>
  <xsl:apply-templates select="*[position()>1]"/>
  <xsl:text>)> </xsl:text>
</xsl:template>

<xsl:template match="xtf:g">
  <xsl:param name="igg-verb"/>
  <xsl:choose>
    <xsl:when test="@gloss">
      <sup>
	<xsl:if test="@gloss='post' 
		and preceding-sibling::*[1][local-name() = 'gloss']">
	  <xsl:text> </xsl:text>
        </xsl:if>
	<xsl:if test="@gloss='cont' 
			and preceding-sibling::xtf:g[@gloss='post']"
		><xsl:text>-</xsl:text></xsl:if>
        <xsl:call-template name="format-g"/>
	<xsl:if test="@gloss='cont' and following-sibling::xtf:g[@gloss='pre']"
		><xsl:text>-</xsl:text></xsl:if>
      </sup>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="format-g">
        <xsl:with-param name="igg-verb" select="$igg-verb"/>
      </xsl:call-template>
      <xsl:if test="(local-name(..)='l') 
	and not(position()=last())">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="format-g">
  <xsl:param name="igg-verb"/>
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="xtf:cmt"/>
<xsl:template match="xtf:protocols|xtf:protocol"/>

<xsl:template match="xtf:*">
  <xsl:variable name="loc" 
	select="ancestor::*[@xml:id][1]/@xml:id"/>
  <xsl:message>xtf-HTML:<xsl:value-of select="$loc"
	/> untrapped element <xsl:value-of 
     select="local-name()"/></xsl:message>
</xsl:template>

<xsl:template name="init-cap">
  <xsl:param name="str"/>
  <xsl:value-of select="translate(substring($str,1,1),$lc,$uc)"/>
  <xsl:value-of select="substring($str,2)"/>
</xsl:template>

<xsl:template match="xtf:note">
  <xsl:choose>
    <xsl:when test="ancestor::xtf:l"/>
    <xsl:otherwise>
      <p class="note">
	<xsl:if test="@notemark|@notelabel">
	  <xsl:attribute name="mark">
	    <xsl:choose>
	      <xsl:when test="@notelabel">
		<xsl:value-of select="@notelabel"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="@notemark"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	</xsl:if>
	<xsl:apply-templates/>
      </p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="after-line" match="xtf:note">
  <tr>
    <td/>
    <td colspan="{ancestor::*[@cols][1]/@cols}">
      <span class="note"><xsl:text>???</xsl:text>
        <xsl:text>(</xsl:text>
          <xsl:apply-templates/>
        <xsl:text>)</xsl:text>
      </span>
    </td>
  </tr>
</xsl:template>

<xsl:template name="format-note">
<!--  <xsl:text>(</xsl:text>
  <span class="note">NOTE: </span>
 -->
  <span class="note"><xsl:apply-templates/></span>
<!--
  <xsl:text>)</xsl:text>
 -->
</xsl:template>

<xsl:template match="xtf:h">
  <tr class="hforce">
    <xsl:attribute name="xml:id"><xsl:value-of select="@xml:id"/></xsl:attribute>
    <xsl:variable name="ncols" select="1+number(ancestor::*[@cols]/@cols)"/>
    <td colspan="{$ncols}">
      <xsl:apply-templates/>
    </td>
  </tr>
</xsl:template>

<xsl:template match="xh:a">
  <span class="marker">
    <xsl:apply-templates/>
  </span>
</xsl:template>

<!-- The content model of S has to be reviewed before it's worth
 putting any real effort into this template -->
<xsl:template match="xtf:s">
  <xsl:choose>
    <xsl:when test="ancestor::xtf:l">
      <xsl:apply-templates/>
    </xsl:when>
    <xsl:otherwise>
      <tr>
	<xsl:apply-templates/>
      </tr>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  Depending on the layout of notes in ETCSL it is probably enough just
  to apply-templates here.
 -->
<xsl:template match="xtf:lvg">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="xtf:wvg">
  <xsl:text> {</xsl:text>
  <xsl:for-each select="*">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">
      <xsl:text>&#xa0;; </xsl:text>
    </xsl:if>
  </xsl:for-each>
  <xsl:text>} </xsl:text>
</xsl:template>

<!--
<xsl:template match="gdl:a">
  <xsl:if test="$drop-allographs=0">
    <xsl:apply-imports/>
  </xsl:if>
</xsl:template>
-->

<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="xcl:xcl"/>

</xsl:stylesheet>
