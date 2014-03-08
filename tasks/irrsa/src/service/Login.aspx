<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="irrsa.Login" %>
<asp:Content runat="server" ContentPlaceHolderID="Header">
<div class="container">
	<form class="form-signin" role="form">
		<h2 class="form-signin-heading">Sign in, Agent</h2>
		<input id="login" type="text" name="login" class="form-control" placeholder="Login" required autofocus>
		<input id="password" type="password" name="pass" class="form-control" placeholder="Password" required>
		<input type="submit" class="btn btn-lg btn-primary btn-block" value="Sign in"/>
		<br/>
		<div id="signin-error" class="alert alert-danger" style="display:none"></div>
		<div id="signin-success" class="alert alert-success" style="display:none"></div>
	</form>
	<script type="text/javascript">
		var fail = function(text) {
			$('#signin-success').hide();
			$('#signin-error').text(text).show();
		};

		var success = function(text) {
			$('#signin-error').hide();
			$('#signin-success').text(text).show();
		};

		$('.form-signin').submit(function (e) {
			$.post('/auth', $(this).serialize(), function(data) {
				if(data && data.error)
					fail(data.error);
				else {
					success(data && data.msg ? data.msg : 'OK');
					window.location = '/';
				}
			}, 'json').fail(function() {
				fail('Unknown error');
			});
			e.preventDefault();
		});
	</script>
</div>
</asp:Content>