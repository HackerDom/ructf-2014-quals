<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NavBar.ascx.cs" Inherits="irrsa.NavBar" %>
<div class="navbar navbar-default" role="navigation">
	<div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="/">Rational Security Agency</a>
		</div>
		<div class="navbar-collapse collapse">
			<ul class="nav navbar-nav">
				<li class="active"><a href="/">Home</a></li>
				<asp:PlaceHolder runat="server" ID="RequestsLink" Visible="False">
					<li><a href="/msglist">Requests</a></li>
				</asp:PlaceHolder>
			</ul>
			<ul class="nav navbar-nav navbar-right">
				<asp:PlaceHolder runat="server" ID="LoggedOut" Visible="True">
					<li><a href="/login">Login</a></li>
				</asp:PlaceHolder>
				<asp:PlaceHolder runat="server" ID="LoggedIn" Visible="False">
					<li class="navbar-login-info"><div><%:Agent%></div></li>
					<li><a href="/topsecret">Top Secret</a></li>
					<li><a href="/logout">Logout</a></li>
				</asp:PlaceHolder>
			</ul>
		</div>
	</div>
</div>