import 'package:flutter_md_edit/models/article.dart';

void saveFile(int articleID, String title, String content) async {
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

Future<bool> autoSaveFile(int articleID, String title, String content) async {
  if (title.isNotEmpty){
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
      await ArticleProvider().insert(article);
    }
    return true;
  }
  return false;
}