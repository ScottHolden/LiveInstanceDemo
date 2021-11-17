const string idFile = "id.txt";

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

Guid id = Guid.NewGuid();

if (File.Exists(idFile))
{
	var txt = await File.ReadAllTextAsync(idFile);
	if (Guid.TryParse(txt, out Guid loadedId))
	{
		id = loadedId;
	}
}

await File.WriteAllTextAsync(idFile, id.ToString());

app.UseDefaultFiles();
app.UseStaticFiles();

app.MapGet("/id", () => id.ToString());

app.Run();
