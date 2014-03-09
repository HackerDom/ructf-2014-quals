using System;
using System.Security.Cryptography;
using System.Web;
using irrsa.utils;

namespace irrsa
{
	public class SaveMsg : BaseHandler
	{
		protected override AjaxResult ProcessRequestInternal(HttpContext context)
		{
			var ssid = AuthModule.GetSsid();

			Guid msgid;
			if(Guid.TryParseExact(context.Request.Form["id"], "N", out msgid))
			{
				//NOTE: Msg approved
				var item = DbStorage.FindMessage(msgid, true);
				if(item == null)
					throw new AjaxException("Message not found");

				var team = BasicAuth.GetLogin();
				if(!Limit.TryUpdate(team, null, Settings.DelayBeforeNextMessageSec))
					throw new AjaxException(string.Format("Not so fast pls, wait {0} sec from last request", Settings.DelayBeforeNextMessageSec));

				DbStorage.AddMessage(item, false);

				return new AjaxResult {Message = "Thank you!"};
			}

			var email = context.Request.Form["email"];
			if(string.IsNullOrEmpty(email))
				throw new AjaxException("Email is empty");
			if(email.Length > Settings.MaxEmailLength)
				throw new AjaxException("Email too long");

			var phone = context.Request.Form["phone"];
			if(string.IsNullOrEmpty(phone))
				throw new AjaxException("Phone is empty");
			if(phone.Length > Settings.MaxPhoneLength)
				throw new AjaxException("Phone too long");

			var text = context.Request.Form["text"];
			if(string.IsNullOrEmpty(text))
				throw new AjaxException("Message is empty");
			if(text.Length > Settings.MaxMessageLength)
				throw new AjaxException("Message size exceeded");

			var ip = context.Request.Headers["X-Forwarded-For"];
			var ua = context.Request.UserAgent.SubstringSafe(0, Settings.MaxUserAgentLength);

			msgid = new Guid(MD5.Create().ComputeHash(Guid.NewGuid().ToByteArray()));
			DbStorage.AddMessage(new DbItem
			{
				Id = msgid,
				SessionId = ssid,
				To = "agent007",
				Email = email,
				Phone = phone,
				Text = text,
				IP = ip != null && !ip.StartsWith("172.") ? ip : null,
				UA = ua,
				Date = DateTime.UtcNow
			}, true);

			return new AjaxResult {Message = "Thank you!", Id = msgid.ToString("N")};
		}
	}
}