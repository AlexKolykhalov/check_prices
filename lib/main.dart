import 'dart:async';

import 'package:check_prices/BLoC/keyboard/keyboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:check_prices/BLoC/products/products_bloc.dart';
import 'package:check_prices/repo/repository.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check prices',
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ProductsBloc(repository: Repository())),
          BlocProvider(
            create: (context) => KeyboardCubit(),
          )
        ],
        child: SafeArea(child: HomePage()),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller;
  ProductsBloc _bloc;
  KeyboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _bloc = context.bloc<ProductsBloc>();
    _cubit = context.bloc<KeyboardCubit>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsLoaded) {
            if (state.data['errors'].isNotEmpty) {
              Scaffold.of(context)
                ..showSnackBar(
                    ErrorSnackBar(size: size, errors: state.data['errors']));
            }
          }
        },
        builder: (context, state) {
          return BlocBuilder<KeyboardCubit, bool>(
            builder: (context, cubit) {
              return Container(
                width: size.width,
                height: size.height,
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.02,
                      vertical: size.height * 0.03,
                    ),
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          showCursor: true,
                          readOnly: cubit,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02),
                            hintText: 'Поиск...',
                          ),
                          onTap: () {
                            print('OnTap');
                            _cubit.readOnlyKeyboard(false);
                          },
                          onChanged: (value) {
                            if (value.length > 2) {
                              _bloc.add(ProductsFetched(search: value));
                            }
                          },
                          controller: _controller,
                        ),
                        (state.data['errors'].isNotEmpty)
                            ? SuffixElementFailure(
                                size: size,
                                controller: _controller,
                                bloc: _bloc)
                            : SuffixElement(
                                size: size,
                                controller: _controller,
                                cubit: _cubit,
                              ),
                      ],
                    ),
                  ),
                  () {
                    if (state is ProductsLoadInProgress) {
                      return Expanded(
                          child: Center(child: CircularProgressIndicator()));
                    }
                    if (state is ProductsLoaded) {
                      if (state.data['products'].isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Text('Ничего не найдено.'),
                          ),
                        );
                      }
                      return Expanded(
                        child: Container(
                          width: size.width,
                          child: ListView.builder(
                            itemBuilder: (context, index) => ListElement(
                              size: size,
                              state: state,
                              index: index,
                            ),
                            itemCount: state.data['products'].length,
                          ),
                        ),
                      );
                    }
                    return Expanded(
                      child: Center(
                        child: Text('Начните поиск.'),
                      ),
                    );
                  }()
                ]),
              );
            },
          );
        },
      ),
    );
  }
}

class ErrorSnackBar extends SnackBar {
  ErrorSnackBar({Key key, Size size, List<dynamic> errors})
      : super(
          key: key,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.white,
          content: Container(
            height: size.height * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.01),
                  child: Text(
                    'Ошибка при получении данных:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _listErrorWidgets(
                      size: size.width * 0.08, errors: errors),
                ),
              ],
            ),
          ),
        );
}

class SuffixElement extends StatelessWidget {
  const SuffixElement({
    Key key,
    @required this.size,
    @required this.controller,
    @required this.cubit,
  }) : super(key: key);

  final Size size;
  final TextEditingController controller;
  final KeyboardCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.1,
      child: IconButton(
        icon: Icon(Icons.close, color: Colors.grey),
        onPressed: () {
          controller.clear();
          cubit.readOnlyKeyboard(true);
        },
      ),
    );
  }
}

class SuffixElementFailure extends StatelessWidget {
  const SuffixElementFailure({
    Key key,
    @required this.size,
    @required this.controller,
    @required this.bloc,
  }) : super(key: key);

  final Size size;
  final TextEditingController controller;
  final ProductsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              controller.clear();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: () {
              bloc.add(ProductsFetched(search: controller.text));
            },
          ),
        ],
      ),
    );
  }
}

class ListElement extends StatelessWidget {
  const ListElement({
    Key key,
    @required this.size,
    @required this.state,
    @required this.index,
  }) : super(key: key);

  final Size size;
  final ProductsState state;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () => _launchURL(url: state.data['products'][index].url),
      onLongPress: () => null,
      contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
      leading: FaviconImage(
        size: size.width * 0.1,
        assetName: state.data['products'][index].logo,
      ),
      title: Text(state.data['products'][index].title),
      subtitle: Text(state.data['products'][index].subtitle),
      trailing: TrailingElement(size: size, state: state, index: index),
    );
  }
}

class FaviconImage extends StatelessWidget {
  const FaviconImage({
    Key key,
    @required this.size,
    @required this.assetName,
  }) : super(key: key);

  final double size;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: size / 4)],
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(assetName),
        ),
      ),
    );
  }
}

class TrailingElement extends StatelessWidget {
  const TrailingElement({
    Key key,
    @required this.size,
    @required this.state,
    @required this.index,
  }) : super(key: key);

  final Size size;
  final ProductsState state;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _listWidgets(product: state.data['products'][index]),
    );
  }
}

Future _launchURL({url}) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

List<Widget> _listWidgets({product}) {
  List<Widget> _list = [];
  _list.add(Text(product.regularPrice));
  for (var cardPrice in product.cardPrice) {
    _list.add(Text(cardPrice.price));
  }
  return _list;
}

List<Widget> _listErrorWidgets({size, errors}) {
  List<Widget> _list = [];
  for (var error in errors) {
    if (error == 'lenta') {
      _list.add(FaviconImage(
        size: size,
        assetName: 'assets/lenta_fav.png',
      ));
      _list.add(SizedBox(width: size));
    } else if (error == 'metro') {
      _list.add(FaviconImage(
        size: size,
        assetName: 'assets/metro_fav.png',
      ));
      _list.add(SizedBox(width: size));
    } else if (error == '5ka') {
      _list.add(FaviconImage(
        size: size,
        assetName: 'assets/5ka_fav.png',
      ));
      _list.add(SizedBox(width: size));
    }
  }
  return _list;
}
