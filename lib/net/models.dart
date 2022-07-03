import 'dart:convert';

class GithubContentsRes {
  String? type;
  String? encoding;
  int? size;
  String? name;
  String? path;
  String? content;
  String? sha;
  String? url;
  String? gitUrl;
  String? htmlUrl;
  String? downloadUrl;

  GithubContentsRes({
    this.type,
    this.encoding,
    this.size,
    this.name,
    this.path,
    this.content,
    this.sha,
    this.url,
    this.gitUrl,
    this.htmlUrl,
    this.downloadUrl,
  });

  GithubContentsRes.fromMap(Map<String, dynamic> map) {
    List<int> byteC = base64Decode(map['content'].trim());

    content = String.fromCharCodes(byteC);
    type = map['type'];
    encoding = map['encoding'];
    size = map['size'];
    name = map['name'];
    path = map['path'];
    sha = map['sha'];
    url = map['url'];
    gitUrl = map['git_url'];
    htmlUrl = map['html_url'];
    downloadUrl = map['download_url'];
  }
}

class GithubContentsPut {
  String? message;
  String? sha;
  String? content;

  GithubContentsPut({
    this.message,
    this.sha,
    this.content,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> maps = {
      'message': message,
      'sha': sha,
      'content': content,
    };
    maps.removeWhere((key, value) => value == null);
    return maps;
  }
}
