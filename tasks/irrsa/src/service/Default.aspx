<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="irrsa.Default" %>
<%@ Register TagPrefix="web" TagName="MsgForm" Src="MsgForm.ascx" %>
<asp:Content runat="server" ContentPlaceHolderID="Title">Welcome to RSA</asp:Content>
<asp:Content runat="server" ContentPlaceHolderID="Header"></asp:Content>
<asp:Content runat="server" ContentPlaceHolderID="Content">
<div class="row">
	<div class="col-md-4">
		<h2>Our Mission</h2>
		<p>Maecenas vel mi sed purus molestie interdum non sed lacus. Nam et elementum nibh, sed congue elit. Morbi sodales tempor lacus eget dignissim. Praesent iaculis mi eget ligula sagittis gravida.</p>
	</div>
	<div class="col-md-4">
		<h2>Our Vision</h2>
		<p>Ut ac tempor lacus. Nulla lobortis mi nisi, elementum interdum sapien fringilla sit amet. Sed dignissim, lorem at tincidunt euismod, mauris tortor consectetur felis, at tincidunt tortor diam in dui.</p>
	</div>
	<div class="col-md-4">
		<h2>Our Values</h2>
		<p>Nam a nisl sit amet enim suscipit elementum. In ullamcorper tellus augue, et rhoncus felis interdum ut. Proin pellentesque ut dolor sit amet molestie. Proin tempus vel elit eget porta.</p>
	</div>
</div>
<div class="row">
	<div class="col-md-12">
		<web:MsgForm runat="server"/>
	</div>
</div>
</asp:Content>