<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="mssngrrr.Default" %>
<%@ Register TagPrefix="web" TagName="MsgForm" Src="MsgForm.ascx" %>
<asp:Content runat="server" ContentPlaceHolderID="Content">
	<div class="jumbotron">
		<h1>Send a message</h1>
		<p class="lead">Send <i>awesome</i> messages to your friends. No registration needed! You need only know your friend's current secure ID.</p>
	</div>
	<web:MsgForm runat="server"/>
</asp:Content>