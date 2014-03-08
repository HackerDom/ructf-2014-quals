using System;
using System.Web.UI;

namespace mssngrrr
{
	public partial class MsgList : UserControl
	{
		protected override void OnLoad(EventArgs e)
		{
			var id = AuthModule.GetUserId();

			Msgs.DataSource = DbStorage.FindMessages(id);
			Msgs.DataBind();
		}
	}
}