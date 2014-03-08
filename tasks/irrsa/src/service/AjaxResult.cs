using System.Runtime.Serialization;

namespace irrsa
{
	[DataContract]
	public class AjaxResult
	{
		[DataMember(Name = "error", EmitDefaultValue = false)] public string Error;
		[DataMember(Name = "msg", EmitDefaultValue = false)] public string Message;
		[DataMember(Name = "id", EmitDefaultValue = false)] public string Id;
	}
}