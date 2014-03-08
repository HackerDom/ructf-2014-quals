<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MsgFormPreview.ascx.cs" Inherits="irrsa.MsgFormPreview" %>
<asp:PlaceHolder runat="server" ID="Content" Visible="False">
<div class="form-request panel panel-info">
	<div class="panel-heading">
		<div class="panel-title"><%:Agent == null ? "Review your request" : "Request from civilian"%></div>
	</div>
	<div class="panel-body">
		<%=Agent != null ? null : "<!-- for agents "%><p class="row"><label class="control-label col-sm-2">ip</label><span class="form-control-static col-sm-10"><%=Item.IP%></span></p>
		<p class="row"><label class="control-label col-sm-2">ua</label><span class="form-control-static col-sm-10"><%=Item.UA%></span></p><%=Agent != null ? null : "-->"%><%--NOTE: XSS HERE :)--%>
		<p class="row"><label class="control-label col-sm-2">email</label><span class="form-control-static col-sm-10"><%:Item.Email%></span></p>
		<p class="row"><label class="control-label col-sm-2">phone</label><span class="form-control-static col-sm-10"><%:Item.Phone%></span></p>
		<p class="row"><label class="control-label col-sm-2">text</label><span class="form-control-static col-sm-10"><%:Item.Text%></span></p>
		<p class="row"><label class="control-label col-sm-2">time</label><span class="form-control-static col-sm-10"><%:Item.Date.ToString("u")%></span></p>
		<asp:PlaceHolder runat="server" ID="Approve" Visible="False">
			<p class="row"><form id="form-approve">
				<div class="checkbox"><label><input type="checkbox" id="checkbox-ok"/>&nbsp;Information is correct</label></div>
				<input type="hidden" name="id" value="<%:Id.ToString("N")%>"/>
				<button id="approve-btn" class="btn btn-primary">approve</button>
				<script type="text/javascript">
					var fail = function(text) {
						$('#approve-success').hide();
						$('#approve-error').text(text).show();
					};

					var success = function(text) {
						$('#approve-error').hide();
						$('#approve-btn').attr('disabled', true);
						$('#approve-success').text(text).show();
						setTimeout(function() {
							window.close();
						}, 2000);
					};

					$('#form-approve').submit(function(e) {
						if(!$('#checkbox-ok').is(":checked")) {
							fail('You must approve that information is correct');
						} else {
							$.post('/submit', $(this).serialize(), function(data) {
								if(data && data.error)
									fail(data.error);
								else
									success(data && data.msg ? data.msg : 'OK');
							}, 'json').fail(function() {
								fail('Unknown error');
							});
						}
						e.preventDefault();
					});
				</script>
			</form></p>
			<div id="approve-error" class="alert alert-danger" style="display:none"></div>
			<div id="approve-success" class="alert alert-success" style="display:none"></div>
		</asp:PlaceHolder>
	</div>
</div>
</asp:PlaceHolder>