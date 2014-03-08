<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NavBar.ascx.cs" Inherits="mssngrrr.NavBar" %>
<%@ Import Namespace="mssngrrr" %>
<div class="header">
	<ul class="nav nav-pills pull-right">
		<li class="disabled navbar-login-info"><a>Your ID: <%:AuthModule.GetUserId().ToString("N")%></a></li>
		<li class="<%:Context.CurrentHandler is Default ? "active" : null%>"><a href="/">Home</a></li>
		<li class="<%:Context.CurrentHandler is Messages ? "active" : null%>"><a href="/messages">Inbox</a></li>
	</ul>
	<h3><a href="/" class="logo">mssngrrr</a></h3>
</div>