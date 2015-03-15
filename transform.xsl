<?xml version="1.0"?>
<!-- vim: set shiftwidth=1 tabstop=2: -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" version="1.0" extension-element-prefixes="exsl">
  <!-- (c) Miek Gieben 2013. Hereby put in the public domain.  Version: 2.11 -->
  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:template match="/">
    <xsl:comment> This document was prepared using Pandoc2rfc, https://github.com/miekg/pandoc2rfc </xsl:comment>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="article">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- Remove the article info section, this should be handled in the <front> matter of the draft -->
  <xsl:template match="articleinfo"/>
  <xsl:template match="footnote">
    <xsl:choose>
     <xsl:when test="child::para/superscript">
        <iref>
          <xsl:attribute name="item">
           <xsl:value-of select="para/superscript"/>
          </xsl:attribute>
          <xsl:attribute name="subitem">
           <xsl:for-each select="./para/text()[not(ancestor::superscript)]">
              <xsl:value-of select="normalize-space(translate(., '&#10;', ' '))"/>
            </xsl:for-each>
          </xsl:attribute>
        </iref>
      </xsl:when>
      <xsl:otherwise>
        <!-- discard -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Merge section with the title tags into one section -->
  <xsl:template match="section | simplesect | sect1 | sect2 | sect3 | sect4 | sect5">
    <section>
      <xsl:attribute name="title">
        <xsl:value-of select="normalize-space(translate(./title, '&#10;', ' '))"/>
      </xsl:attribute>
      <xsl:attribute name="anchor">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </section>
  </xsl:template>
  <!-- Transform a <para> to <t>, not in lists, then it is discarded -->
  <xsl:template match="para | simpara">
    <xsl:choose>
      <xsl:when test="parent::listitem">
        <xsl:if test="position() &gt; 2">
          <vspace blankLines="1"/>
        </xsl:if>
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="ancestor::tbody">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <t>
          <xsl:apply-templates/>
        </t>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Transform a <listitem> to a <t> for lists, except in description lists -->
  <xsl:template match="listitem">
    <xsl:choose>
      <xsl:when test="parent::varlistentry">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <t>
          <xsl:apply-templates/>
        </t>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Transform lists, for lists in list we do not put it in a new <t></t> -->
  <xsl:template match="orderedlist/listitem/para/emphasis">
    <xsl:choose>
      <xsl:when test="@role = 'strikethrough'"/>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="orderedlist">
    <xsl:choose>
      <!-- style="format ..." -->
      <xsl:when test="listitem/para/emphasis/@role = 'strikethrough'">
        <xsl:choose>
          <xsl:when test="ancestor::orderedlist">
            <list>
              <xsl:attribute name="style">
                <xsl:value-of select="concat('format ', listitem/para/emphasis)"/>
              </xsl:attribute>
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::itemizedlist">
            <list>
              <xsl:attribute name="style">
                <xsl:value-of select="concat('format ', listitem/para/emphasis)"/>
              </xsl:attribute>
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::variablelist">
            <list>
              <xsl:attribute name="style">
                <xsl:value-of select="concat('format ', listitem/para/emphasis)"/>
              </xsl:attribute>
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:otherwise>
            <t>
              <list>
                <xsl:attribute name="style">
                  <xsl:value-of select="concat('format ', listitem/para/emphasis)"/>
                </xsl:attribute>
                <xsl:apply-templates/>
              </list>
            </t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(@numeration,'arabic')">
        <xsl:choose>
          <xsl:when test="ancestor::orderedlist">
            <list style="numbers">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::itemizedlist">
            <list style="numbers">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::variablelist">
            <list style="numbers">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:otherwise>
            <t>
              <list style="numbers">
                <xsl:apply-templates/>
              </list>
            </t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(@numeration,'lowerroman')">
        <xsl:choose>
          <xsl:when test="ancestor::orderedlist">
            <list style="format %i.">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::itemizedlist">
            <list style="format %i.">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::variablelist">
            <list style="format %i.">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:otherwise>
            <t>
              <list style="format %i.">
                <xsl:apply-templates/>
              </list>
            </t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(@numeration,'upperroman')">
        <xsl:choose>
          <xsl:when test="ancestor::orderedlist">
            <list style="format (%d)">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::itemizedlist">
            <list style="format (%d)">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::variablelist">
            <list style="format (%d)">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:otherwise>
            <t>
              <list style="format (%d)">
                <xsl:apply-templates/>
              </list>
            </t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(@numeration,'upperalpha')">
        <xsl:choose>
          <xsl:when test="ancestor::orderedlist">
            <list style="format %C.">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::itemizedlist">
            <list style="format %C.">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::variablelist">
            <list style="format %C.">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:otherwise>
            <t>
              <list style="format %C.">
                <xsl:apply-templates/>
              </list>
            </t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(@numeration,'loweralpha')">
        <xsl:choose>
          <xsl:when test="ancestor::orderedlist">
            <list style="letters">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::itemizedlist">
            <list style="letters">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::variablelist">
            <list style="letters">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:otherwise>
            <t>
              <list style="letters">
                <xsl:apply-templates/>
              </list>
            </t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="ancestor::orderedlist">
            <list style="empty">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::itemizedlist">
            <list style="empty">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:when test="ancestor::variablelist">
            <list style="empty">
              <xsl:apply-templates/>
            </list>
          </xsl:when>
          <xsl:otherwise>
            <t>
              <list style="empty">
                <xsl:apply-templates/>
              </list>
            </t>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="itemizedlist">
    <xsl:choose>
      <xsl:when test="ancestor::orderedlist">
        <list style="symbols">
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:when test="ancestor::itemizedlist">
        <list style="symbols">
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:when test="ancestor::variablelist">
        <list style="symbols">
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:otherwise>
        <t>
          <list style="symbols">
            <xsl:apply-templates/>
          </list>
        </t>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Hanging lists are specified as <variablelist> -->
  <xsl:template match="variablelist">
    <xsl:choose>
      <xsl:when test="ancestor::orderedlist">
        <list style="hanging">
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:when test="ancestor::itemizedlist">
        <list style="hanging">
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:when test="ancestor::variablelist">
        <list style="hanging">
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:otherwise>
        <t>
          <list style="hanging">
            <xsl:apply-templates/>
          </list>
        </t>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="varlistentry">
    <t>
      <xsl:attribute name="hangText">
        <xsl:value-of select="normalize-space(translate(./term,        ' &#9;&#13;&#10;', ' '))"/>
      </xsl:attribute>
      <!-- OPTION: enable this to get a newline after the hangText -->
      <!-- <xsl:element name="vspace"/> -->
      <xsl:apply-templates select="./listitem"/>
    </t>
  </xsl:template>
  <!-- Transform <link> to <xref> crosslinks -->
  <xsl:template match="link">
    <xref>
      <xsl:attribute name="target">
        <xsl:value-of select="@linkend"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xref>
  </xsl:template>
  <!-- Transform <ulink> to <eref> links -->
  <xsl:template match="ulink">
    <eref>
      <xsl:attribute name="target">
        <xsl:value-of select="@url"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </eref>
  </xsl:template>
  <!-- Deal with line blocks -->
  <xsl:template match="literallayout">
    <xsl:apply-templates/>
    <!-- hack assuming in a literal layout, we want to see a newline -->
    <vspace/>
  </xsl:template>
  <!-- Transform <blockquote> to <list style="empty"> -->
  <xsl:template match="blockquote">
    <xsl:choose>
      <xsl:when test="parent::listitem">
        <list style="empty">
          <xsl:apply-templates/>
        </list>
      </xsl:when>
      <xsl:otherwise>
        <t>
          <list style="empty">
            <xsl:apply-templates/>
          </list>
        </t>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Transform <programlisting> to <figure><artwork> -->
  <xsl:template match="screen | programlisting">
    <figure>
      <xsl:if test="normalize-space(substring-before(following-sibling::*[position()=1][name()='para']/footnote/para, '::')) != ''">
        <xsl:attribute name="anchor">
          <xsl:value-of select="normalize-space(substring-before(following-sibling::*[position()=1][name()='para']/footnote/para, '::'))"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="normalize-space(substring-after(following-sibling::*[position()=1][name()='para']/footnote/para, '::')) != ''">
        <xsl:attribute name="align">
          <xsl:text>center</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="normalize-space(substring-after(following-sibling::*[position()=1][name()='para']/footnote/para, '::'))"/>
        </xsl:attribute>
      </xsl:if>
      <artwork>
        <xsl:if test="normalize-space(substring-after(following-sibling::*[position()=1][name()='para']/footnote/para, '::')) != ''">
          <xsl:attribute name="align">
            <xsl:text>center</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="."/>
      </artwork>
    </figure>
  </xsl:template>
  <xsl:template match="title"/>
  <xsl:template match="literal">
    <xsl:choose>
      <xsl:when test="parent::emphasis">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <spanx style="verb">
          <xsl:apply-templates/>
        </spanx>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="emphasis">
    <xsl:choose>
      <!-- spanx inside spanx it not supported -->
      <xsl:when test="parent::emphasis">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="contains(@role,'strong')">
            <spanx style="strong">
              <xsl:apply-templates/>
            </spanx>
          </xsl:when>
          <xsl:otherwise>
            <spanx style="emph">
              <xsl:apply-templates/>
            </spanx>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Tables -->
  <xsl:template match="table | informaltable">
    <texttable>
      <xsl:if test="normalize-space(substring-before(following-sibling::*[position()=1][name()='para']/footnote/para, '::')) != ''">
        <xsl:attribute name="anchor">
          <xsl:value-of select="normalize-space(substring-before(following-sibling::*[position()=1][name()='para']/footnote/para, '::'))"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="normalize-space(substring-after(following-sibling::*[position()=1][name()='para']/footnote/para, '::')) != ''">
        <xsl:attribute name="align">
          <xsl:text>center</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="normalize-space(substring-after(following-sibling::*[position()=1][name()='para']/footnote/para, '::'))"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </texttable>
  </xsl:template>
  <!-- Table headers -->
  <xsl:template match="table/thead/tr/th | informaltable/thead/tr/th">
    <ttcol>
      <xsl:attribute name="align">
        <xsl:value-of select="@align"/>
      </xsl:attribute>
      <!--
Every even position() need to be dealt with: 
2 look back to 1, 4 look back to 2, etc.
-->
      <xsl:if test="position() = 2">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="1"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 4">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="2"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 6">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="3"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 8">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="4"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 10">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="5"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 12">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="6"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 14">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="7"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 16">
        <xsl:call-template name="get_col">
          <xsl:with-param name="column" select="8"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates/>
    </ttcol>
  </xsl:template>
  <xsl:template name="get_col">
    <xsl:param name="column"/>
    <xsl:if test="../../../col[$column]">
      <xsl:attribute name="width">
        <xsl:value-of select="../../../col[$column]/@width"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <!-- Table headers for CALS tables -->
  <xsl:template match="table/tgroup/thead/row/entry">
    <ttcol>
      <xsl:if test="position() = 2">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="1"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 4">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="2"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 6">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="3"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 8">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="4"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 10">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="5"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 12">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="6"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 14">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="7"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 16">
        <xsl:call-template name="get_colspec">
          <xsl:with-param name="column" select="8"/>
        </xsl:call-template>
      </xsl:if>
      <!-- If the entry itself has align, we use that -->
      <xsl:if test="@align">
        <xsl:attribute name="align">
          <xsl:value-of select="@align"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </ttcol>
  </xsl:template>
  <xsl:template name="get_colspec">
    <xsl:param name="column"/>
    <xsl:if test="../../../../tgroup/colspec[$column]">
      <xsl:attribute name="align">
        <xsl:value-of select="../../../../tgroup/colspec[$column]/@align"/>
      </xsl:attribute>
      <!-- Optionally colwidth, translate * to % -->
      <xsl:if test="../../../../tgroup/colspec[$column]/@colwidth">
        <xsl:attribute name="width">
          <xsl:value-of select="translate(../../../../tgroup/colspec[$column]/@colwidth, '*', '%')"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <!-- Table headers for CALS tables, Pandoc 1.9.x+ -->
  <xsl:template match="informaltable/tgroup/thead/row/entry">
    <ttcol>
      <xsl:if test="position() = 2">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="1"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 4">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="2"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 6">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="3"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 8">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="4"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 10">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="5"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 12">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="6"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 14">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="7"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="position() = 16">
        <xsl:call-template name="get_colspec_informal">
          <xsl:with-param name="column" select="8"/>
        </xsl:call-template>
      </xsl:if>
      <!-- If the entry itself has align, we use that -->
      <xsl:if test="@align">
        <xsl:attribute name="align">
          <xsl:value-of select="@align"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </ttcol>
  </xsl:template>
  <xsl:template name="get_colspec_informal">
    <xsl:param name="column"/>
    <xsl:if test="../../../../tgroup/colspec[$column]">
      <xsl:attribute name="align">
        <xsl:value-of select="../../../../tgroup/colspec[$column]/@align"/>
      </xsl:attribute>
      <!-- Optionally colwidth, translate * to % -->
      <xsl:if test="../../../../tgroup/colspec[$column]/@colwidth">
        <xsl:attribute name="width">
          <xsl:value-of select="translate(../../../../tgroup/colspec[$column]/@colwidth,'*', '%')"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template match="table/tbody/tr/td | informaltable/tbody/tr/td | table/tgroup/tbody/row/entry | informaltable/tgroup/tbody/row/entry">
    <c>
      <xsl:apply-templates/>
    </c>
  </xsl:template>
  <!-- CALS table -->
  <xsl:template match="table/tbody/row/entry">
    <c>
      <xsl:apply-templates/>
    </c>
  </xsl:template>
  <!-- Allow embedded PIs and other one-offs -->
  <xsl:template match="para/processing-instruction('rfc')">
    <xsl:processing-instruction name="rfc">
      <xsl:value-of select="."/>
    </xsl:processing-instruction>
  </xsl:template>
  <xsl:template match="para/vspace">
    <vspace>
      <xsl:if test="@blankLines">
        <xsl:attribute name="blankLines">
          <xsl:value-of select="@blankLines"/>
        </xsl:attribute>
      </xsl:if>
    </vspace>
  </xsl:template>
</xsl:stylesheet>
