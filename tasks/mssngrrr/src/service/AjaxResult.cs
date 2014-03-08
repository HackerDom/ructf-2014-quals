using System.Runtime.Serialization;

namespace mssngrrr
{
	[DataContract]
	public class AjaxResult
	{
		[DataMember(Name = "name", EmitDefaultValue = false)] public string Name;
		[DataMember(Name = "length", EmitDefaultValue = false)] public int Length;
		[DataMember(Name = "message", EmitDefaultValue = false)] public string Message;
		[DataMember(Name = "error", EmitDefaultValue = false)] public string Error;
	}
}