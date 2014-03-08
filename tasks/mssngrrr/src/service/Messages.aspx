<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Messages.aspx.cs" Inherits="mssngrrr.Messages" %>
<%@ Register TagPrefix="web" TagName="MsgList" Src="MsgList.ascx" %>
<asp:Content ContentPlaceHolderID="Content" runat="server">
	<web:MsgList runat="server"/>
</asp:Content>