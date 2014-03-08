using System;
using System.Web;
using log4net;

namespace mssngrrr
{
	public class SaveMsg : BaseHandler
	{
		protected  override AjaxResult ProcessRequestInternal(HttpContext context)
		{
			var id = AuthModule.GetUserId();

			Guid to;
			if(!Guid.TryParseExact(context.Request.Form["to"], "N", out to))
				throw new AjaxException("Invalid recipient");

			var subject = context.Request.Form["subject"];
			if(subject.Length > Settings.MaxSubjectLength)
				throw new AjaxException("Subject too long");

			var theme = context.Request.Form["theme"];

			var text = context.Request.Form["text"];
			if(text.Length > Settings.MaxMessageLength)
				throw new AjaxException("Message size exceeded");

			var img = context.Request.Form["img"];
			if(img.Length > Settings.MaxImageFilenameLength)
				throw new AjaxException("Image filename too long");

			var team = BasicAuth.GetLogin();
			if(to == Settings.Admin)
			{
				if(!Limit.TryIncrement(team, "admin", Settings.DelayBeforeNextMessageToAdminSec))
					throw new AjaxException(string.Format("User {0} limit msg rate, pls wait {1} sec from last msg", to.ToString("N"), Settings.DelayBeforeNextMessageToAdminSec));
			}
			else
			{
				if(!Limit.TryIncrement(team, "user", Settings.DelayBeforeNextMessageToUserSec))
					throw new AjaxException(string.Format("Not so fast pls, wait {0} sec from last msg", Settings.DelayBeforeNextMessageToUserSec));
			}

			var msgid = Guid.NewGuid();
			DbStorage.AddMessage(new DbItem
			{
				Id = msgid,
				From = id,
				To = to,
				Subject = subject,
				Theme = theme,
				Text = text,
				Img = img == string.Empty ? null : img
			});

			Log.InfoFormat("Saved message '{0}' to '{1}'", msgid, to.ToString("N"));

			return new AjaxResult {Message = "OK"};
		}

		private static readonly ILog Log = LogManager.GetLogger(typeof(SaveMsg));
	}
}