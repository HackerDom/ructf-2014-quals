using System;
using System.Web.UI;

namespace irrsa
{
	public partial class MsgFormPreview : UserControl
	{
		protected override void OnLoad(EventArgs e)
		{
			var ssid = AuthModule.GetSsid();

			Agent = AuthModule.FindAgentName();
			var agentLoggedIn = Agent == null;

			Item = DbStorage.FindMessage(Id, agentLoggedIn);
			if(Item == null || (Item.SessionId != ssid && agentLoggedIn))
				return;

			Approve.Visible = agentLoggedIn;

			Content.Visible = true;
		}

		public Guid Id;

		protected DbItem Item;
		protected string Agent;
	}
}