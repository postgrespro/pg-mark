<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/TR/REC-html40">

<xsl:output indent="yes" method="html" version = "4.0"/>

<xsl:template match="/">
<html>
  <head>
    <title>Postgres benchmarking results</title>
  </head>
  <style type="text/css">
td {
    text-align: right
}

tr td:first-child {
    text-align: left
}

tr th {
    text-align: center
}
  </style>
  <body>
<xsl:apply-templates/>
  </body>
</html>
</xsl:template>

<xsl:template match="benchmarking/run">
  <h3>Benchmarking run started at <xsl:value-of select="@started"/>
  <xsl:if test="@ended">, ended at <xsl:value-of select="@ended"/></xsl:if>
  </h3>
  <div>
  <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template name="replace-string">
  <xsl:param name="text"/>
  <xsl:param name="replace"/>
  <xsl:param name="with"/>
  <xsl:choose>
    <xsl:when test="contains($text, $replace)">
    <xsl:value-of select="substring-before($text,$replace)"/>
    <xsl:value-of select="$with"/>
    <xsl:call-template name="replace-string">
      <xsl:with-param name="text" select="substring-after($text,$replace)"/>
      <xsl:with-param name="replace" select="$replace"/>
      <xsl:with-param name="with" select="$with"/>
    </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
    <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="benchmark">
  <table border="1" cellspacing="0">
  <caption>Benchmark <xsl:value-of select="@id"/></caption>
  <thead><tr><th>Instance</th>
  <xsl:for-each select="instance/metric/@id[not(. = ../../preceding-sibling::instance/metric/@id)]">
  <xsl:sort data-type="number" order="descending" />
  <th>
        <xsl:call-template name="replace-string">
            <xsl:with-param name="text" select="."/>
            <xsl:with-param name="replace" select="'_'" />
            <xsl:with-param name="with" select="'_&#8203;'"/>
        </xsl:call-template>
  </th>
  </xsl:for-each>
  </tr></thead>
  <tbody>
  <xsl:for-each select="instance">
    <xsl:variable name="inst" select="."/>
    <tr><td><xsl:value-of select="@id"/></td>
    <xsl:for-each select="../instance/metric/@id[not(. = ../../preceding-sibling::instance/metric/@id)]">
      <xsl:sort data-type="number" order="descending" />
      <td>
      <xsl:variable name="mid" select="." />
      <xsl:variable name="val" select="$inst/metric[@id=$mid]/@value" />
      <xsl:choose>
        <xsl:when test="$val!=''">
            <xsl:choose>
                <xsl:when test="$mid='version'">
                    <xsl:value-of select="$val"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number($val, '0.00')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            &#160;
        </xsl:otherwise>
      </xsl:choose>
      </td>
    </xsl:for-each>
    </tr>
  </xsl:for-each>
  </tbody>
  </table>
  <br />
</xsl:template>

</xsl:stylesheet>
