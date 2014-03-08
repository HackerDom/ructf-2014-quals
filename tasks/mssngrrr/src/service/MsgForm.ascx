<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MsgForm.ascx.cs" Inherits="mssngrrr.MsgForm" %>
<%@ Import Namespace="mssngrrr" %>
<form id="msgform" method="POST" class="container-narrow send-msg-form">
	<p><input type="text" name="to" class="form-control" value="" maxlength="32" placeholder="to"/></p>
	<p><input type="text" name="subject" class="form-control" value="" maxlength="<%:Settings.MaxSubjectLength%>" placeholder="subject"/></p>
	<p><textarea class="form-control" name="text" placeholder="message" maxlength="<%:Settings.MaxMessageLength / 2%>" rows="7"></textarea></p>
	<p><select class="form-control" name="theme">
		<option value="" selected disabled class="hidden">...select theme...</option>
		<option value="rainy">Rainy day</option>
		<option value="winter">Winter is coming</option>
	</select></p>
	
	<div class="row">
		<div class="col-xs-5">
			<div class="btn btn-default btn-sm btn-block fileinput-button">
<%--				<i class="glyphicon glyphicon-plus"></i>--%>
				<span><b>+</b>&nbsp;Attach photo...</span>
				<input type="file" id="fileupload" name="file"/>
			</div>
		</div>
		<div class="col-xs-7">
			<div id="progress" class="progress fileinput-progress">
				<div class="progress-bar"></div>
			</div>
		</div>
	</div>

	<br/><div id="files" class="alert" style="display:none"></div>

	<input id="send-msg-form-img" type="hidden" name="img"/>
	
	<div class="row">
		<div class="col-lg-5">
			<button type="submit" class="btn btn-primary btn-block">Send!</button>
		</div>
<%--		<div class="col-lg-7">--%>
<%--			<button type="button" class="btn btn-link">Preview</button>--%>
<%--		</div>--%>
	</div>

	<br/><div id="save-result" class="alert" style="display:none"></div>
</form>

<script type="text/javascript">
	$(function () {
		var saved = function(cls, text) {
			$('#save-result').addClass(cls).text(text).fadeIn('fast');
		};
		var savefail = function(error) {
			saved('alert-danger', error);
		};

		$('#msgform').submit(function (e) {
			$('#save-result').removeClass('alert-danger').removeClass('alert-success').hide();
			$.post('/savemsg', $(this).serialize(), function (data) {
				if(data && data.error)
					savefail(data.error);
				else
					saved('alert-success', 'OK');
			}, 'json').fail(function () {
				savefail('Unknown error');
			});
			e.preventDefault();
		});

		var res = function(cls, text) {
			$('#files').addClass(cls).text(text).fadeIn('fast');
		};
		var fail = function (e, data) {
			res('alert-danger', data && data.result ? data.result.error : 'Unknown error');
			$('#progress .progress-bar').addClass('progress-bar-warning');
			$('#send-msg-form-img').val('');
		};
		var done = function(e, data) {
			if(data && data.result && data.result.name) {
				res('alert-success', data.result.name);
				$('#progress .progress-bar').addClass('progress-bar-success');
				$('#send-msg-form-img').val(data.result.name);
			}
			else
				fail(e, data);
		};

		var setprogress = function(progress) {
			$('#progress .progress-bar').css('width', progress + '%');
		};

		$('#fileupload').fileupload({
			url: '/upload',
			dataType: 'json',
			done: done,
			fail: fail,
			change: function () {
				$('#progress .progress-bar').removeClass('progress-bar-success').removeClass('progress-bar-warning');
				$("#files").removeClass('alert-danger').removeClass('alert-success').hide();
				setprogress(0);
			},
			progressall: function (e, data) {
				var progress = parseInt(data.loaded / data.total * 100, 10);
				setprogress(progress);
			}
		});
	});
</script>