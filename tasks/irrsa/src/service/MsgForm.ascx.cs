using System.Web.UI;

namespace irrsa
{
	public partial class MsgForm : UserControl
	{
		protected override void OnLoad(System.EventArgs e)
		{
			var agent = AuthModule.FindAgentName();
			SendForm.Visible = agent == null;
		}
	}
}