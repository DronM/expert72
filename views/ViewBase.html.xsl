<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:variable name="BASE_PATH" select="/document/model[@id='ModelVars']/row[1]/basePath"/>
<xsl:variable name="VERSION" select="/document/model[@id='ModelVars']/row[1]/scriptId"/>
<xsl:variable name="TITLE" select="/document/model[@id='ModelVars']/row[1]/title"/>
<xsl:variable name="TOKEN">
	<xsl:choose>
		<xsl:when test="not(/document/model[@id='ModelVars']/row[1]/token='')"><xsl:value-of select="concat('&amp;token=',/document/model[@id='ModelVars']/row[1]/token)"/></xsl:when>
		<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
</xsl:variable>
	
	
<!--************* Main template ******************** -->		
<xsl:template match="/document">
<html>
	<head>
		<xsl:call-template name="initHead"/>
		
		<script>
			function pageLoad(){				
				<xsl:call-template name="initApp"/>
				
				<xsl:if test="/document/model[@id='ModelServResponse']/row/result='1'">
					throw Error(CommonHelper.longString(function () {/*
					<xsl:value-of select="/document/model[@id='ModelServResponse']/row/descr"/>
					*/}));
				</xsl:if>	
				
				<xsl:call-template name="modelFromTemplate"/>
			}
		</script>
	</head>
	<body onload="pageLoad();">
	
		<xsl:call-template name="page_header"/>
		
		<!-- Page container -->
		<div class="page-container">

			<!-- Page content -->
			<div class="page-content">

				<!-- Main sidebar -->
				<div class="sidebar sidebar-main">
					<div class="sidebar-content">
						<xsl:call-template name="initMenu"/>					
					</div>
				</div>
				
				<!-- Main content -->
				<div class="content-wrapper">

					<!-- Content area -->
					<div class="content">
						<div class="row">
							<div id="windowData" class="col-lg-12">
								<xsl:apply-templates select="model[@htmlTemplate='TRUE']"/>
							</div>

							<div class="windowMessage hidden">
							</div>
						</div>
						
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


<!--************* Javascript files ******************** -->
<xsl:template name="initJS">
	<!-- bootstrap resolution-->
	<div id="users-device-size">
	  <div id="xs" class="visible-xs"></div>
	  <div id="sm" class="visible-sm"></div>
	  <div id="md" class="visible-md"></div>
	  <div id="lg" class="visible-lg"></div>
	</div>

	<iframe id="file_downloader" style="display:none;"></iframe>
	
	<!--ALL js modules -->
	<xsl:apply-templates select="model[@id='ModelJavaScript']/row"/>
	
</xsl:template>


<!--************* Application instance ******************** -->
<xsl:template name="initApp">
	
	var application = new AppExpert({
		servVars:{
			<xsl:for-each select="model[@id='ModelVars']/row/*">
			<xsl:if test="position() &gt; 1">,</xsl:if>"<xsl:value-of select="local-name()"/>":'<xsl:value-of select="node()"/>'
			</xsl:for-each>
		}
		<xsl:if test="model[@id='ConstantValueList_Model']">
		,"constantXMLString":CommonHelper.longString(function () {/*
				<xsl:copy-of select="model[@id='ConstantValueList_Model']"/>
		*/})
		</xsl:if>
		<!--	
		<xsl:if test="/document/model[@id='ModelServResponse']/row/result='1'">
			,
			"error":"<xsl:value-of select="/document/model[@id='ModelServResponse']/row/descr"/>"
		</xsl:if>	
		-->
	});
	<xsl:call-template name="initAppWin"/>
		
	<!-- [@default='FALSE']-->
	<xsl:variable name="def_menu_item" select="//menuItem[@default='TRUE']"/>
	<xsl:if test="$def_menu_item">
	if(window.location.href.indexOf("?") &lt; 0 || window.location.href.indexOf("token=") &gt;=0) {
		var iRef = DOMHelper.getElementsByAttr("true", CommonHelper.nd("side-menu"), "defaultItem",true,"A")[0];
		application.showMenuItem(iRef,'<xsl:value-of select="$def_menu_item/@c"/>','<xsl:value-of select="$def_menu_item/@f"/>','<xsl:value-of select="$def_menu_item/@t"/>');
	}
	</xsl:if>
	
</xsl:template>

<!--************* Window instance ******************** -->
<xsl:template name="initAppWin">	
	var applicationWin = new AppWin({
		"bsCol":("col-"+$('#users-device-size').find('div:visible').first().attr('id')+"-"),
		"app":application
		<!--
		<xsl:if test="/document/model[@id='ModelServResponse']/row/result='1'">
			,"error":"<xsl:value-of select="/document/model[@id='ModelServResponse']/row/descr"/>"
		</xsl:if>	
		-->
	});
	
</xsl:template>

<!--************* Page head ******************** -->
<xsl:template name="initHead">
	<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<link href="https://fonts.googleapis.com/css?family=Roboto:400,300,100,500,700,900" rel="stylesheet" type="text/css" />
	
	<xsl:apply-templates select="model[@id='ModelVars']"/>
	<xsl:apply-templates select="model[@id='ModelStyleSheet']/row"/>
	<link rel="icon" type="image/png" href="img/favicon.png"/>
	
	<title>Управление государственной экспертизы проектной документации</title>
</xsl:template>


<!-- ************** Main Menu ******************** -->
<xsl:template name="initMenu">
	<xsl:if test="model[@id='MainMenu_Model']">
	<!-- Main navigation -->
	<div class="sidebar-category sidebar-category-visible">
		<div class="category-content no-padding">
			<ul class="navigation navigation-main navigation-accordion">

				<!-- Main -->				
				
				<xsl:apply-templates select="/document/model[@id='MainMenu_Model']/menu/*"/>
				
				<xsl:if test="/document/model[@id='ModelVars']/row/role_id='admin'">
				<!-- service -->
				<li>
					<a href="#" class="has-ul"><i class="icon-stack2"></i> <span>Сервис</span></a>
					<ul class="hidden-ul" style="display: none;">
						<li>
							<a href="index.php?c=View_Controller&amp;f=get_list&amp;t=ViewList"
							onclick="window.getApp().showMenuItem(this,'View_Controller','get_list','ViewList');return false;">
							Все формы
							</a>
						</li>		        				
				
						<li>
							<a href="index.php?c=Constant_Controller&amp;f=get_list&amp;t=ConstantList"
							onclick="window.getApp().showMenuItem(this,'Constant_Controller','get_list','ConstantList');return false;">
							Константы
							</a>
						</li>		        				
				
						<li>
							<a href="index.php?c=MainMenuConstructor_Controller&amp;f=get_list&amp;t=MainMenuConstructorList"
							onclick="window.getApp().showMenuItem(this,'MainMenuConstructor_Controller','get_list','MainMenuConstructorList');return false;">
							Конструктор меню
							</a>
						</li>		        				
						<li>
							<a href="#" onclick="window.getApp().showAbout();return false;">
							О программе
							</a>
						</li>
					</ul>
				</li>
				
				</xsl:if>
			</ul>
		</div>
	</div>
	</xsl:if>
</xsl:template>


<!--************* Menu item ******************-->
<xsl:template match="menuitem">
	<xsl:choose>
		<xsl:when test="menuitem">
			<!-- multylevel @isgroup='1'-->			
			<li>
				<a href="#" class="has-ul"><i class="{@glyphclass}"></i> <span><xsl:value-of select="@descr"/> </span></a>
				<ul class="hidden-ul" style="display: none;">
					<xsl:apply-templates/>
					<!--
					<xsl:for-each select="*">
					<li>
					    <a href="index.php?c={@c}&amp;f={@f}&amp;t={@t}{$TOKEN}"
					    onclick="window.getApp().showMenuItem(this,'{@c}','{@f}','{@t}{$TOKEN}');return false;"
					    defaultItem="{@default='TRUE'}">
					    <xsl:if test="@glyphclass"><i class="{@glyphclass}"></i></xsl:if>
					    <xsl:value-of select="@descr"/> </a>
					</li>								
					</xsl:for-each>
					-->
				</ul>						
			</li>
		</xsl:when>
		<xsl:otherwise>
			<!-- one level-->
			<li>
			    <a href="index.php?c={@c}&amp;f={@f}&amp;t={@t}{$TOKEN}"
			    onclick="window.getApp().showMenuItem(this,'{@c}','{@f}','{@t}{$TOKEN}');return false;"
			    defaultItem="{@default='TRUE'}">
			    <xsl:if test="@glyphclass"><i class="{@glyphclass}"></i></xsl:if>
			    <xsl:value-of select="@descr"/> </a>
			</li>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<!--
<xsl:template match="menuitem">
	<xsl:choose>
		<xsl:when test="@isgroup='1'">
			<li>
				<a href="#" class="has-ul"><i class="{@glyphclass}"></i> <span><xsl:value-of select="@descr"/> </span></a>
				<ul class="hidden-ul" style="display: none;">
					<xsl:apply-templates/>
				</ul>						
			</li>
		</xsl:when>
		<xsl:otherwise>
			<li>
			    <a href="index.php?c={@c}&amp;f={@f}&amp;t={@t}{$TOKEN}"
			    onclick="window.getApp().showMenuItem(this,'{@c}','{@f}','{@t}{$TOKEN}');return false;"
			    defaultItem="{@default='TRUE'}">
			    <xsl:if test="@glyphclass"><i class="{@glyphclass}"></i></xsl:if>
			    <xsl:value-of select="@descr"/> </a>
			</li>			
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
-->
<!--*************** templates ********************* -->
<xsl:template match="model[@templateId]">
<xsl:copy-of select="*"/>
</xsl:template>

<xsl:template name="modelFromTemplate">
	
	<!-- All data models to namespace -->
	var models = {};
	<xsl:for-each select="model[not(@sysModel='1')]">
	<xsl:variable name="m_id" select="@id"/>
	models.<xsl:value-of select="$m_id"/> = new <xsl:value-of select="$m_id"/>({
		"data":CommonHelper.longString(function () {/*
			<xsl:copy-of select="/document/model[@id=$m_id]"/>
		*/})
	});
	</xsl:for-each>
	
	<xsl:for-each select="model[@templateId]">
		var v_<xsl:value-of select="@templateId"/> = new <xsl:value-of select="@templateId"/>_View("<xsl:value-of select="@templateId"/>",{
			"app":application,
			"models":models,
			"template":CommonHelper.longString(function () {/*
			<xsl:copy-of select="./*"/>
			*/}),
			"variantStorage":{
				"name":"<xsl:value-of select="@templateId"/>"
				<xsl:if test="/document/model[@id='VariantStorage_Model']">
				,"model":models.VariantStorage_Model
				</xsl:if>			
			}			
		});
		v_<xsl:value-of select="@templateId"/>.toDOM(CommonHelper.nd("windowData"));	
	</xsl:for-each>
</xsl:template>


<!-- ERROR 
<xsl:template match="model[@id='ModelServResponse']/row/result='1'">
throw Error(CommonHelper.longString(function () {/*
<xsl:value-of select="descr"/>
*/}));
</xsl:template>
-->

<!--System variables -->
<xsl:template match="model[@id='ModelVars']/row">
	<xsl:if test="author">
		<meta name="Author" content="{author}"></meta>
	</xsl:if>
	<xsl:if test="keywords">
		<meta name="Keywords" content="{keywords}"></meta>
	</xsl:if>
	<xsl:if test="description">
		<meta name="Description" content="{description}"></meta>
	</xsl:if>
	
</xsl:template>

<!-- CSS -->
<xsl:template match="model[@id='ModelStyleSheet']/row">	
	<link rel="stylesheet" href="{concat(href,'?',$VERSION)}" type="text/css"/>
</xsl:template>

<!-- Javascript -->
<xsl:template match="model[@id='ModelJavaScript']/row">
	<script src="{concat(href,'?',$VERSION)}"></script>
</xsl:template>

<!-- Error
<xsl:template match="model[@id='ModelServResponse']/row">
	<xsl:if test="result/node()='1'">
	<div class="error"><xsl:value-of select="descr"/></div>
	</xsl:if>
</xsl:template>
 -->

<xsl:template name="page_header">
	<!-- Main navbar -->
	<div class="navbar navbar-inverse">
		<xsl:choose>
		<xsl:when test="/document/model[@id='ModelVars']/row/role_id=''">
		<div class="navbar-header">
			<a class="navbar-brand" href="index.php">Управление государственной экспертизы проектной документации.
			625048 г.Тюмень ул. М. Горького д. 76, 5-й эт.приёмная: (3452) 56-54-90
			</a>
		</div>
		</xsl:when>
		<xsl:otherwise>
		<div class="navbar-header">
			<a class="navbar-brand" href="index.php">Управление государственной экспертизы проектной документации.</a>
		</div>
		
		<div class="navbar-collapse collapse" id="navbar-mobile">
			<ul class="nav navbar-nav">
				<li><a class="sidebar-control sidebar-main-toggle hidden-xs"><i class="icon-paragraph-justify3"></i></a></li>
			</ul>
			<p class="navbar-text"><span class="label bg-success">В сети</span></p>		
			<ul class="nav navbar-nav navbar-right">
				
				<!-- USER DATA -->
				<li class="dropdown dropdown-user">
					<a class="dropdown-toggle" data-toggle="dropdown">
						<img src="assets/images/placeholder.jpg" alt=""/>
						<span><xsl:apply-templates select="/document/model[@id='ModelVars']/row/user_name"/></span>
						<i class="caret"></i>
					</a>

					<ul class="dropdown-menu dropdown-menu-right">
						<li>
							<a href="index.php?c=User_Controller&amp;f=get_profile&amp;t=UserProfile{$TOKEN}"
							onclick="window.getApp().showMenuItem(this,'User_Controller','get_profile','UserProfile{$TOKEN}');return false;">
							<i class="icon-user-plus"></i> Профиль
							</a>
						</li>					        
						
						<li><a href="#"><span class="badge bg-teal-400 pull-right">58</span> <i class="icon-comment-discussion"></i> Сообщения</a></li>
						<li class="divider"></li>
						<li><a href="index.php?c=User_Controller&amp;f=logout_html{$TOKEN}"><i class="icon-switch2"></i> Выход</a></li>
					</ul>
				</li>				
			</ul>
		</div>
		</xsl:otherwise>
		</xsl:choose>
	</div>
	<!-- /main navbar -->
</xsl:template>

</xsl:stylesheet>
