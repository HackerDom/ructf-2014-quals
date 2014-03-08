using System;
using System.Web.UI;

namespace mssngrrr
{
	public partial class Preview : Page
	{
		protected override void OnLoad(EventArgs e)
		{
			Guid msgid;
			if(!Guid.TryParse(Context.Request.QueryString["id"], out msgid))
				return;

			MsgPreview.MsgId = msgid;
		}
	}
}