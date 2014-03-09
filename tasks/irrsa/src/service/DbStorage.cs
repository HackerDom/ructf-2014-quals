using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using irrsa.utils;

namespace irrsa
{
	public static class DbStorage
	{
		public static bool Auth(string login, string pass)
		{
			return Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("select [login] from agents where [login] = @login and [pass] = @pass",
				cmd =>
				{
					cmd.AddParam("login", login, DbType.String);
					cmd.AddParam("pass", pass, DbType.String);
					var reader = cmd.ExecuteReader();
					return reader.HasRows;
				}));
		}

		public static string FindLogin(Guid ssid)
		{
			return Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("select top(1) [login] from sessions where [ssid] = @ssid order by [n] desc",
				cmd =>
				{
					cmd.AddParam("ssid", ssid, DbType.Guid);
					return cmd.ExecuteScalar() as string;
				}));
		}

		public static void AddSessionId(string login, Guid ssid)
		{
			Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("insert into sessions ([login], [ssid]) values (@login, @ssid)",
				cmd =>
				{
					cmd.AddParam("login", login, DbType.String);
					cmd.AddParam("ssid", ssid, DbType.Guid);
					cmd.ExecuteNonQuery();
				}));
		}

		/*public static void RemoveSessionId(Guid ssid)
		{
			Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("delete from sessions where ssid = @ssid",
				cmd =>
				{
					cmd.AddParam("ssid", ssid, DbType.Guid);
					cmd.ExecuteNonQuery();
				}));
		}*/

		public static void AddMessage(DbItem item, bool preview)
		{
			Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("insert into " + (preview ? "msg_temp" : "msg") + " ([id], [ssid], [to], [email], [phone], [text], [ip], [ua], [dt]) values (@id, @ssid, @to, @email, @phone, @text, @ip, @ua, @dt)",
				cmd =>
				{
					cmd.AddParam("id", item.Id, DbType.Guid);
					cmd.AddParam("ssid", item.SessionId, DbType.Guid);
					cmd.AddParam("to", item.To, DbType.String);
					cmd.AddParam("email", item.Email, DbType.String);
					cmd.AddParam("phone", item.Phone, DbType.String);
					cmd.AddParam("text", item.Text, DbType.String);
					cmd.AddParam("ip", item.IP, DbType.String);
					cmd.AddParam("ua", item.UA, DbType.String);
					cmd.AddParam("dt", item.Date, DbType.DateTime2);
					cmd.ExecuteNonQuery();
				}));
		}

		public static DbItem FindMessage(Guid id, bool preview)
		{
			return Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("select top(1) [id], [ssid], [to], [email], [phone], [text], [ip], [ua], [dt] from " + (preview ? "msg_temp" : "msg") + " where id = @id",
				cmd =>
				{
					cmd.AddParam("id", id, DbType.Guid);
					var reader = cmd.ExecuteReader();
					return Iterate(reader).FirstOrDefault();
				}));
		}

		public static IEnumerable<DbItem> FindMessages(string to)
		{
			return Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("select top(20) [id], [ssid], [to], [email], [phone], [text], [ip], [ua], [dt] from msg where to = @to",
				cmd =>
				{
					cmd.AddParam("to", to, DbType.Guid);
					var reader = cmd.ExecuteReader();
					return Iterate(reader).ToList();
				}));
		}

		private static IEnumerable<DbItem> Iterate(DbDataReader reader)
		{
			while(!reader.IsClosed && reader.Read())
			{
				yield return
					new DbItem
					{
						Id = reader.GetGuid(0),
						SessionId = reader.GetGuid(1),
						To = reader.GetString(2),
						Email = reader.TryGetString(3),
						Phone = reader.TryGetString(4),
						Text = reader.TryGetString(5),
						IP = reader.TryGetString(6),
						UA = reader.TryGetString(7),
						Date = reader.GetDateTime(8)
					};
			}
		}
	}
}