<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="ViewBase.html.xsl"/>

<xsl:template match="/document">
<html>
	<head>
		<xsl:call-template name="initHead"/>		
		<title>Подтверждение электронной почты</title>
	</head>
	
	<body>

	<xsl:call-template name="page_header"/>

	<!-- Page container -->
	<div class="page-container">

		<!-- Page content -->
		<div class="page-content">

			<!-- Main content -->
			<div class="content-wrapper">

				<!-- Content area -->
				<div class="content">
					<xsl:choose>
					<xsl:when test="/document/model[@id='ModelServResponse']/row/result='0'">
						<h1>Адрес электронной почты подтвержден!</h1>
					</xsl:when>
					<xsl:otherwise>
						<h4>Ошибка подтвержения электронной почты: <strong><xsl:value-of select="/document/model[@id='ModelServResponse']/row/descr"/></strong></h4>
					</xsl:otherwise>
					</xsl:choose>
					<!-- Footer -->
					<div class="footer text-muted text-center">
						2017. <a href="#">Катрэн+</a>
					</div>
					<!-- /footer -->

				</div>
				<!-- /content area -->

			</div>
			<!-- /main content -->

		</div>
		<!-- /page content -->

	</div>
	<!-- /page container -->
		
		<xsl:call-template name="initJS"/>
	</body>
</html>		
</xsl:template>

</xsl:stylesheet>
