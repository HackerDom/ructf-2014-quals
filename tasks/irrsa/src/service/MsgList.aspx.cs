using System;
using System.Web.UI;

namespace irrsa
{
	public partial class MsgList : Page
	{
		protected override void OnLoad(EventArgs e)
		{
			//NOTE: stub
			Response.Redirect("/login?back=%2fmsglist", true);
		}
	}
}