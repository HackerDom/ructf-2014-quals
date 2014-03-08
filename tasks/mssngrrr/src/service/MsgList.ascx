<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MsgList.ascx.cs" Inherits="mssngrrr.MsgList" %>
<%@ Import Namespace="mssngrrr.utils" %>
<div class="table-responsive">
	<table class="table table-striped table-hover">
		<thead>
			<tr>
				<th>from</th>
				<th>subject</th>
				<th>msg</th>
			</tr>
		</thead>
		<tbody>
	<asp:Repeater runat="server" ID="Msgs" ItemType="mssngrrr.DbItem">
		<ItemTemplate>
			<tr class="msg-row" data-id="<%#Item.Id.ToString("N")%>">
				<td><%#:Item.From.ToString("N")%></td>
				<td><%#:Item.Subject.Shorten(20, 30)%></td>
				<td><%#:Item.Text.Shorten(40, 60)%></td>
			</tr>
		</ItemTemplate>
	</asp:Repeater>
		</tbody>
	</table>
	<script type="text/javascript">
		$(".msg-row").click(function() {
			window.location = "/preview?id=" + $(this).data("id");
		});
	</script>
</div>