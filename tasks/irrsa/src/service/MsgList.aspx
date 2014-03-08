<%@ Page Language="C#" MasterPageFile="~/Main.Master" AutoEventWireup="true" CodeBehind="MsgList.aspx.cs" Inherits="irrsa.MsgList"  %>
<%@ Import Namespace="irrsa.utils" %>
<asp:Content ContentPlaceHolderID="Title" runat="server">Check this requests</asp:Content>
<asp:Content ContentPlaceHolderID="Content" runat="server">
<div class="table-responsive">
	<table class="table table-striped table-hover">
		<thead>
			<tr>
				<th>email</th>
				<th>phone</th>
				<th>text</th>
			</tr>
		</thead>
		<tbody>
	<asp:Repeater runat="server" ID="Msgs" ItemType="irrsa.DbItem">
		<ItemTemplate>
			<tr>
				<td><%#:Item.Email%></td>
				<td><%#:Item.Phone%></td>
				<td><%#:Item.Text.Shorten(40, 60)%></td>
			</tr>
		</ItemTemplate>
	</asp:Repeater>
		</tbody>
	</table>
</div>
</asp:Content>