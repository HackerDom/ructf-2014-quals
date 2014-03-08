using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using mssngrrr.utils;

namespace mssngrrr
{
	public static class DbStorage
	{
		public static void AddMessage(DbItem item)
		{
			Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("insert into msg ([id], [from], [to], [subject], [theme], [text], [img]) values (@id, @from, @to, @subject, @theme, @text, @img)",
				cmd =>
				{
					cmd.AddParam("id", item.Id, DbType.Guid);
					cmd.AddParam("from", item.From, DbType.Guid);
					cmd.AddParam("to", item.To, DbType.Guid);
					cmd.AddParam("subject", item.Subject, DbType.String);
					cmd.AddParam("theme", item.Theme, DbType.String);
					cmd.AddParam("text", item.Text, DbType.String);
					cmd.AddParam("img", item.Img, DbType.String);
					cmd.ExecuteNonQuery();
				}));
		}

		public static IEnumerable<DbItem> FindMessages(Guid to)
		{
			return Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("select top(20) [id], [from], [to], [subject], [theme], [text], [img] from msg where [to] = @to order by [n] desc",
				cmd =>
				{
					cmd.AddParam("to", to, DbType.Guid);
					var reader = cmd.ExecuteReader();
					return Iterate(reader).ToList();
				}));
		}

		public static DbItem FindMessageById(Guid id)
		{
			return Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("select top(1) [id], [from], [to], [subject], [theme], [text], [img] from msg where [id] = @id order by [n] desc",
				cmd =>
				{
					cmd.AddParam("id", id, DbType.Guid);
					var reader = cmd.ExecuteReader();
					return Iterate(reader).FirstOrDefault();
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
						From = reader.GetGuid(1),
						To = reader.GetGuid(2),
						Subject = reader.TryGetString(3),
						Theme = reader.TryGetString(4),
						Text = reader.TryGetString(5),
						Img = reader.TryGetString(6)
					};
			}
		}
	}
}