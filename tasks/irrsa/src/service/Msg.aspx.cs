using System;
using System.Web.UI;

namespace irrsa
{
	public partial class Msg : Page
	{
		protected override void OnLoad(EventArgs e)
		{
			Guid id;
			Guid.TryParseExact(Context.Request.QueryString["id"], "N", out id);
			Preview.Id = id;

			((Main)Master).WrapperHead.Visible = false;
		}
	}
}