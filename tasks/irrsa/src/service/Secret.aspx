<%@ Page Title="" Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="Secret.aspx.cs" Inherits="irrsa.Secret" %>
<%@ Import Namespace="irrsa" %>
<asp:Content ContentPlaceHolderID="Title" runat="server">
	<asp:PlaceHolder runat="server" ID="FlagField"><%:Settings.Flag%></asp:PlaceHolder>
</asp:Content>