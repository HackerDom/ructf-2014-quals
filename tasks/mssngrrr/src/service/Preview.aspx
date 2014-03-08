<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Preview.aspx.cs" Inherits="mssngrrr.Preview" %>
<%@ Register TagPrefix="web" TagName="MsgPreview" Src="MsgPreview.ascx" %>
<asp:Content ContentPlaceHolderID="Content" runat="server">
	<web:MsgPreview runat="server" ID="MsgPreview"/>
</asp:Content>