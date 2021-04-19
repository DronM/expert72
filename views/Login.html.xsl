<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="ViewBase.html.xsl"/>

<xsl:template match="/document">
<html>
	<head>
		<xsl:call-template name="initHead"/>		
		
		<script>		
			function pageLoad(){
			
				<xsl:call-template name="initApp"/>
				
				var view = new Login_View("Login");
				view.toDOM();
			}
		</script>		
		
	</head>
	<body onload="pageLoad();" class="login-container">

	<xsl:call-template name="page_header"/>

	<!-- Page container -->
	<div class="page-container">

		<!-- Page content -->
		<div class="page-content">

			<!-- Main content -->
			<div class="content-wrapper">

				<!-- Content area -->
				<div class="content">

					<!-- Advanced login -->
					<form id="Login">
						<div class="panel panel-body login-form">
							<div class="text-center">
							<!-- slate-300-->
								<div class="icon-object border-{$COLOR_PALETTE} text-{$COLOR_PALETTE}"><i class="icon-reading"></i></div>
								<h5 class="content-group">Личный кабинет <small class="display-block">Ваши данные</small></h5>
								<div id="Login:error"></div>
							</div>

							<div class="form-group has-feedback has-feedback-left">
								<input id="Login:user" type="text" class="form-control" placeholder="Имя или адрес электронной почты"/>
								<div class="form-control-feedback">
									<i class="icon-user text-muted"></i>
								</div>
								<div id="Login:user:error"/>
							</div>

							<div class="form-group has-feedback has-feedback-left">
								<input id="Login:pwd" type="password" class="form-control" placeholder="Пароль"/>
								<div class="form-control-feedback">
									<i class="icon-lock2 text-muted"></i>
								</div>
								<div id="Login:pwd:error"/>
							</div>

							<div class="form-group login-options">
								<div class="row">
									<!--
									<div class="col-sm-6">
										<label class="checkbox-inline">
										<input id="Login:rememberMe" type="checkbox" class="styled" checked="checked"/>
										Запомнить</label>
									</div>
									-->
									<div class="col-sm-6 text-right">
										<a href="index.php?v=PasswordRecovery">Забыли пароль?</a>
									</div>
								</div>
							</div>
							
							<!-- IE8 condition -->
							<xsl:comment><![CDATA[[if IE 8]>
							<div class="alert alert-danger alert-styled-left alert-bordered">К сожалению, работа в личном кабинете с данным браузером невозможна!
							</div>
							<![endif]]]></xsl:comment>
							
							<div class="form-group">
								<div id="Login:submit_login" class="btn bg-{$COLOR_PALETTE} btn-block">Войти <i class="icon-arrow-right14 position-right"></i></div>
							</div>

							<!--
							<div class="content-divider text-muted form-group"><span>или авторизуйтесь через</span></div>
							<ul class="list-inline form-group list-inline-condensed text-center">
								<li><a href="#" class="btn border-indigo text-indigo btn-flat btn-icon btn-rounded"><i class="icon-facebook"></i></a></li>
								<li><a href="#" class="btn border-pink-300 text-pink-300 btn-flat btn-icon btn-rounded"><i class="icon-dribbble3"></i></a></li>
								<li><a href="#" class="btn border-slate-600 text-slate-600 btn-flat btn-icon btn-rounded"><i class="icon-github"></i></a></li>
								<li><a href="#" class="btn border-info text-info btn-flat btn-icon btn-rounded"><i class="icon-twitter"></i></a></li>
							</ul>
							-->
							<div class="content-divider text-muted form-group"><span>Не зарегистрированы?</span></div>
							<a href="index.php?v=Registration" class="btn btn-default btn-block content-group">Регистрация</a>
						</div>
					</form>
					<!-- /advanced login -->


					<!-- Footer -->
					<div class="footer text-muted text-center">
						2017-2021 <a href="#">Катрэн+</a>
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
		
	<script>
			var n = document.getElementById("Login:user");
			if (n){
				if (document.activeElement &amp;&amp; document.activeElement.id!="Login:pwd"){
					n.focus();
				}
			}
	</script>
		
		<xsl:call-template name="initJS"/>
		
	</body>
</html>		
</xsl:template>

</xsl:stylesheet>
