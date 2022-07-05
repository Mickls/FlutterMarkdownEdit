import 'package:flutter_md_edit/models/article.dart';

void saveFile(int articleID, String title, String content) async {
  // if (!title.endsWith('.md')){
  //   title = '$title.md';
  // }
  if (articleID != 0) {
    Article article = Article(
      title: title,
      content: content,
      superFolderID: 0,
      isDraft: 0,
    );
    await ArticleProvider()
        .update(article, articleID);
  } else {
    Article article = Article(
      title: title,
      content: content,
      superFolderID: 0,
      isDraft: 0,
    );
    await ArticleProvider().insert(article);
  }
}

Future<int> autoSaveFile(int articleID, String title, String content) async {
  if (title.isNotEmpty){
    // if (!title.endsWith('.md')){
    //   title = '$title.md';
    // }
    if (articleID != 0) {
      Article article = Article(
        title: title,
        content: content,
        superFolderID: 0,
        isDraft: 0,
      );
      await ArticleProvider()
          .update(article, articleID);
    } else {
      Article article = Article(
        title: title,
        content: content,
        superFolderID: 0,
        isDraft: 1,
      );
      articleID = await ArticleProvider().insert(article);
    }
    return articleID;
  }
  return articleID;
}