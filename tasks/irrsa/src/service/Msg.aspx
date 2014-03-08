<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Msg.aspx.cs" Inherits="irrsa.Msg" %>
<%@ Register TagPrefix="web" TagName="MsgFormPreview" Src="MsgFormPreview.ascx" %>
<asp:Content ContentPlaceHolderID="Content" runat="server">
	<web:MsgFormPreview runat="server" Id="Preview"/>
</asp:Content>