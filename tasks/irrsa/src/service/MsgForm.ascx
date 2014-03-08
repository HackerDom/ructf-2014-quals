<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MsgForm.ascx.cs" Inherits="irrsa.MsgForm" %>
<%@ Import Namespace="irrsa" %>
<asp:PlaceHolder runat="server" ID="SendForm" Visible="False">
<form class="form-request panel panel-info">
	<div class="panel-heading">
		<div class="panel-title">Submit your anonymous request</div>
	</div>
	<div class="panel-body">
		<p><input type="email" name="email" class="form-control" value="" maxlength="<%:Settings.MaxEmailLength%>" placeholder="email" required/></p>
		<p><input type="tel" name="phone" class="form-control" value="" maxlength="<%:Settings.MaxPhoneLength%>" placeholder="phone" required/></p>
		<p><textarea name="text" class="form-control" maxlength="<%:Settings.MaxMessageLength / 2%>" placeholder="text" required></textarea></p>
		<p><button type="submit" class="btn btn-primary">submit</button></p>
		<div id="send-error" class="alert alert-danger" style="display:none"></div>
		<div id="send-success" class="alert alert-success" style="display:none"></div>
	</div>
</form>
<script type="text/javascript">
	var fail = function(text) {
		$('#send-success').hide();
		$('#send-error').text(text).show();
	};

	var success = function(text) {
		$('#send-error').hide();
		//$('#send-success').text(text).show();
		$(".form-request").hide();
	};

	$('.form-request').submit(function(e) {
		$.post('/submit', $(this).serialize(), function (data) {
			if(data && data.error)
				fail(data.error);
			else {
				success(data && data.msg ? data.msg : 'OK');
				window.open("/msg?id=" + data.id, "msg", "width=800,height=540,scrollbars=yes");
			}
		}, 'json').fail(function () {
			fail('Unknown error');
		});
		e.preventDefault();
	});
</script>
</asp:PlaceHolder>