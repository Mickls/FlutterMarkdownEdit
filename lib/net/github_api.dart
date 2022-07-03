import 'package:dio/dio.dart';
import 'package:flutter_md_edit/contains/github_path.dart';
import 'package:flutter_md_edit/net/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> addCommentHeader(Map<String, dynamic> maps) async {
  var prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('github_token');
  maps["Authorization"] = "token $token";
  return maps;
}

///
/// 获取客户端连接
///
Future<Dio> getClient() async {
  Map<String, dynamic> header = {};
  final option = BaseOptions(headers: await addCommentHeader(header));
  Dio client = Dio(option);
  return client;
}

///
/// 获取仓库名称
///
Future<String> getRepoName() async{
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('github_repo') ?? "";
}

///
/// 获取github用户名
///
Future<String> getGithubUsername() async{
  var prefs = await SharedPreferences.getInstance();
  return prefs.getString('github_name') ?? "";
}

///
/// 拼接文件路径
///
Future<String> getContentsPath(String contentPath) async {
  final repoName = await getRepoName();
  final githubName = await getGithubUsername();

  return "$githubHost/repos/$githubName/$repoName/contents/$contentPath";
}

///
/// 获取文件
///
Future<GithubContentsRes> getContents(String contentPath) async {
  final url = await getContentsPath(contentPath);

  Dio client = await getClient();
  final res = await client.get(url);

  return GithubContentsRes.fromMap(res.data);
}

///
/// 上传或更新文件
/// 更新文件需要传sha
///
Future<GithubContentsRes> putContents(String contentPath, String content, {String sha=""}) async {
  final url = await getContentsPath(contentPath);
  Dio client = await getClient();

  GithubContentsPut putObj = GithubContentsPut("commit $contentPath", sha, content);
  final res = await client.put(
    url,
    data: putObj.toMap(),
  );
  return GithubContentsRes.fromMap(res.data);
}

///
/// 删除文件
///
void delContents(String contentPath, String sha) async {
  final url = await getContentsPath(contentPath);
  Dio client = await getClient();

  GithubContentsPut putObj = GithubContentsPut("commit $contentPath", "", sha);
  await client.delete(
    url,
    data: putObj.toMap(),
  );
}
