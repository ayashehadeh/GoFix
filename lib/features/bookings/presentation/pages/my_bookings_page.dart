import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gofix_bottom_nav_bar.dart';
import '../../../../injection_container.dart' as di;
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../bloc/bookings_bloc.dart';
import '../bloc/bookings_event.dart';
import '../bloc/bookings_state.dart';
import '../widgets/booking_list_card.dart';
import 'booking_info_page.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    context.read<BookingsBloc>().add(LoadUpcomingBookings());
  }

  void _switchTab(bool isUpcoming) {
    final bloc = context.read<BookingsBloc>();
    if (isUpcoming) {
      bloc.add(LoadUpcomingBookings());
    } else {
      bloc.add(LoadPastBookings());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _BookingsHeader(onSwitchTab: _switchTab),
            Expanded(
              child: BlocBuilder<BookingsBloc, BookingsState>(
                builder: (context, state) {
                  if (state is BookingsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    );
                  }

                  if (state is BookingsError) {
                    return _ErrorBody(
                      message: state.message,
                      onRetry: () => context.read<BookingsBloc>().add(
                        LoadUpcomingBookings(),
                      ),
                    );
                  }

                  if (state is BookingsLoaded) {
                    final bookings = state.activeList;
                    if (bookings.isEmpty) {
                      return _EmptyBody(isUpcoming: state.isUpcomingTab);
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return BookingListCard(
                          booking: booking,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => di.sl<BookingsBloc>(),
                                  child: BookingInfoPage(bookingId: booking.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),

      /*bottomNavigationBar: GoFixBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<HomeBloc>(),
                  child: const HomePage(),
                ),
              ),
            );
          }
          if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),*/
      bottomNavigationBar: GoFixBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) return;
          if (index == 2) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _BookingsHeader extends StatelessWidget {
  final void Function(bool isUpcoming) onSwitchTab;

  const _BookingsHeader({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Bookings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: navigate to favourites
                    },
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: () {
                      // TODO: navigate to messages
                    },
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<BookingsBloc, BookingsState>(
            builder: (context, state) {
              final isUpcoming = state is BookingsLoaded
                  ? state.isUpcomingTab
                  : true;
              return _TabToggle(
                isUpcoming: isUpcoming,
                onSwitchTab: onSwitchTab,
              );
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  final bool isUpcoming;
  final void Function(bool) onSwitchTab;

  const _TabToggle({required this.isUpcoming, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'Upcoming',
          isSelected: isUpcoming,
          onTap: () => onSwitchTab(true),
        ),
        const SizedBox(width: 8),
        _TabButton(
          label: 'Past',
          isSelected: !isUpcoming,
          onTap: () => onSwitchTab(false),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  final bool isUpcoming;
  const _EmptyBody({required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.calendar_today_outlined : Icons.history,
            size: 56,
            color: AppColors.divider,
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'No upcoming bookings' : 'No past bookings yet',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
