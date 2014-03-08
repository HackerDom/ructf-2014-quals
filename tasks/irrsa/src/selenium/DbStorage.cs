using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using irrsatest.utils;

namespace irrsatest
{
	internal static class DbStorage
	{
		public static List<Guid> FindNotReadMessages(string to, int top)
		{
			return Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("select top(" + top + ") [id] from msg where [to] = @to and [read] = 0 order by [n] asc",
				cmd =>
				{
					cmd.AddParam("to", to, DbType.String);
					var reader = cmd.ExecuteReader();
					return Iterate(reader).ToList();
				}));
		}

		public static void SetMessageRead(Guid msgid)
		{
			Settings.ConnectionString.UsingConnection(conn => conn.UsingCommand("update msg set [read] = 1 where [id] = @id",
				cmd =>
				{
					cmd.AddParam("id", msgid, DbType.Guid);
					cmd.ExecuteNonQuery();
				}));
		}

		private static IEnumerable<Guid> Iterate(DbDataReader reader)
		{
			while(!reader.IsClosed && reader.Read())
			{
				yield return reader.GetGuid(0);
			}
		}
	}
}