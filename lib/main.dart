import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:check_prices/BLoC/product/product_cubit.dart';
import 'package:check_prices/BLoC/product/product_state.dart';
import 'package:check_prices/BLoC/textfield/textfield_state.dart';
import 'package:check_prices/BLoC/textfield/textfield_cubit.dart';
import 'package:check_prices/models/models.dart';

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
          BlocProvider(create: (context) => TextFieldCubit()),
          BlocProvider(create: (context) => ProductCubit())
        ],
        child: SafeArea(child: HomePage()),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _size.width * 0.02,
              vertical: _size.height * 0.03,
            ),
            child: Stack(
              children: [
                BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, state) {
                    return BlocListener<TextFieldCubit, TextFieldState>(
                      child: TextField(
                        controller: _controller,
                        showCursor: true,
                        enabled: state is Loading ? false : true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: _size.width * 0.02,
                          ),
                          hintText: 'Поиск...',
                        ),
                        onSubmitted: (value) {
                          if (value.length > 2) {
                            context.read<ProductCubit>().load(value);
                          }
                        },
                      ),
                      listener: (context, state) {
                        if (state is Cleared) {
                          _controller.clear();
                        }
                        if (state is Reloaded) {
                          if (_controller.text != "") {
                            context.read<ProductCubit>().load(_controller.text);
                          }
                        }
                      },
                    );
                  },
                ),
                Positioned(right: 0.0, child: SuffixWidget()),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is Loading) {
                  return Center(
                    key: Key('_circularProgressIndicator'),
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is Loaded) {
                  if (state.products.isEmpty) {
                    return Center(child: Text('Ничего не найдено.'));
                  }
                  return Container(
                    key: Key('_listView'),
                    width: _size.width,
                    child: ListView.builder(
                      itemBuilder: (context, index) => ListElement(
                        product: state.products[index],
                      ),
                      itemCount: state.products.length,
                    ),
                  );
                }
                return Center(child: Text('Начните поиск.'));
              },
              listener: (context, state) {
                if (state is Loaded) {
                  if (state.errors.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.white,
                        content: Container(
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? _size.height * 0.12
                              : _size.width * 0.12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ошибка при получении данных:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Flexible(
                                child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) => Center(
                                          child: FaviconImage(
                                            assetName: state.errors[index],
                                          ),
                                        ),
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(width: 15.0),
                                    itemCount: state.errors.length),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SuffixWidget extends StatelessWidget {
  const SuffixWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is Loaded) {
          if (state.errors.isEmpty) {
            return const CleanIconButton();
          }
          return const RefreshCleanIconButton();
        }
        return Container();
      },
    );
  }
}

class CleanIconButton extends StatelessWidget {
  const CleanIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        key: Key('_closeIcon'),
        icon: Icon(Icons.close, color: Colors.grey),
        onPressed: () => context.read<TextFieldCubit>().clear(),
      ),
    );
  }
}

class RefreshCleanIconButton extends StatelessWidget {
  const RefreshCleanIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () => context.read<TextFieldCubit>().clear(),
          ),
          IconButton(
            key: Key('_refreshIcon'),
            icon: Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: () => context.read<TextFieldCubit>().reload(),
          ),
        ],
      ),
    );
  }
}

class ListElement extends StatelessWidget {
  const ListElement({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        if (await canLaunch(product.url)) {
          await launch(product.url);
        } else {
          throw 'Could not launch $product.url';
        }
      },
      contentPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      leading: FaviconImage(assetName: product.logo),
      title: Text(product.title),
      subtitle: Text(product.subtitle),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            product.regularPrice,
            style:
                product.cardPrice.length > 2 ? TextStyle(fontSize: 12.0) : null,
          ),
          ...product.cardPrice
              .map(
                (CardPrice cardPrice) => Text(
                  cardPrice.price,
                  style: product.cardPrice.length > 2
                      ? TextStyle(fontSize: 12.0)
                      : null,
                ),
              )
              .toList()
        ],
      ),
    );
  }
}

class FaviconImage extends StatelessWidget {
  const FaviconImage({
    Key? key,
    required this.assetName,
  }) : super(key: key);

  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10.0)],
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/${assetName}_fav.png'),
        ),
      ),
    );
  }
}
