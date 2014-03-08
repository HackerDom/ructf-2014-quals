<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MsgPreview.ascx.cs" Inherits="mssngrrr.MsgPreview" %>
<asp:PlaceHolder runat="server" ID="Content" Visible="False">
<div class="panel panel-info">
	<div class="panel-heading">
		<div class="row">
			<div class="col-md-8"><h3 class="panel-title"><%:Item.Subject%></h3></div>
			<div class="col-md-4"><div class="pull-right text-muted small">from&nbsp;<%:Item.From.ToString("N")%></div></div>
		</div>
	</div>
	<div class="panel-body">
		<asp:PlaceHolder runat="server" ID="Img" Visible="False">
			<img class="img-thumbnail" src="<%:ImgPath%>"/><br/><br/>
		</asp:PlaceHolder>
		<pre><%:Item.Text%></pre>
	</div>
	<asp:PlaceHolder runat="server" ID="ThemeFiles" Visible="False">
		<link href="static/css/themes/<%:Item.Theme%>.min.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="/static/js/themes/<%:Item.Theme%>.min.js"></script>
	</asp:PlaceHolder>
</div>
</asp:PlaceHolder>