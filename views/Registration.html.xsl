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
				
				var view = new Registration_View("Registration");
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
					<form id="Registration">
						<div class="panel panel-body login-form">
							<div class="text-center">
								<div class="icon-object border-teal text-teal"><i class="icon-plus3"></i></div>
								<h5 class="content-group">Регистрация <small class="display-block">Все поля обязательны для заполнения</small></h5>
								<span id="Registration:error"/>
							</div>

							<div class="content-divider text-muted form-group"><span>Данные для авторизации</span></div>

							<div class="form-group has-feedback has-feedback-left">
								<input id="Registration:name" type="text" class="form-control" placeholder="Имя пользователя"/>
								<div class="form-control-feedback">
									<i class="icon-user-check text-muted"></i>
								</div>
								<span id="Registration:name:error"/>
							</div>

							<div class="form-group has-feedback has-feedback-left">
								<input id="Registration:pwd" type="password" class="form-control" placeholder="Пароль"/>
								<div class="form-control-feedback">
									<i class="icon-user-lock text-muted"></i>
								</div>
								<span id="Registration:pwd:error"/>
							</div>

							<div class="form-group has-feedback has-feedback-left">
								<input id="Registration:pwd_confirm" type="password" class="form-control" placeholder="Подтверждение пароля"/>
								<div class="form-control-feedback">
									<i class="icon-user-lock text-muted"></i>
								</div>
								<span id="Registration:pwd_confirm:error"/>
							</div>

							<div class="content-divider text-muted form-group"><span>Личные данные</span></div>

							<div class="form-group has-feedback has-feedback-left">
								<input id="Registration:email" type="text" class="form-control" placeholder="Адрес электронной почты"/>
								<div class="form-control-feedback">
									<i class="icon-mention text-muted"></i>
								</div>
								<span id="Registration:email:error"/>
							</div>

							<div class="content-divider text-muted form-group"><span>Дополнительные данные</span></div>

							<div class="form-group has-feedback has-feedback-left">
								<input id="Registration:name_full" type="text" class="form-control" placeholder="ФИО пользователя"/>
								<div class="form-control-feedback">
									<i class="icon-user-check text-muted"></i>
								</div>
								<span id="Registration:name_full:error"/>
							</div>

							<div class="form-group">

								<div class="checkbox">
									<label>
										<input id="Registration:pers_data_proc_agreement" type="checkbox" class="styled"/>
										Согласен на обработку персональных данных
									</label>
								</div>
							</div>

							<div id="Registration:captcha"/>

							<div id="Registration:submit" class="btn bg-teal btn-block btn-lg">Зарегистрировать <i class="icon-circle-right2 position-right"></i></div>
						</div>
					</form>
					<!-- /advanced login -->


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
		
	<script>
			var n = document.getElementById("Registration:user");
			if (n){
				if (document.activeElement &amp;&amp; document.activeElement.id!="Registration:user"){
					n.focus();
				}
			}
	</script>
		
		<xsl:call-template name="initJS"/>
	</body>
</html>		
</xsl:template>

</xsl:stylesheet>
